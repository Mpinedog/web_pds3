class ManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_manager, only: [:show, :edit, :update, :destroy, :assign_locker, :synchronize, :check_connection]
  before_action :authorize_user!, only: [:show, :edit, :update, :destroy, :assign_locker]
  require 'base64'

  def index
    @managers = current_user.managers
  end

  def show
    @manager = Manager.find_by(id: params[:id])
    if @manager.nil?
      redirect_to managers_path, alert: "Manager not found."
    else
      @available_lockers = Locker.where(manager_id: nil)
  
      # Verificar si hay un mensaje en el caché para el manager
      flash_message = Rails.cache.read("manager_#{@manager.id}_flash")
      if flash_message
        flash[:notice] = flash_message
        Rails.cache.delete("manager_#{@manager.id}_flash") # Limpiar el mensaje después de mostrarlo
      end
    end
  end
  
  
  
  
  def new
    @manager = Manager.new
  end

  def create
    @manager = current_user.managers.build(manager_params)
    if @manager.save
      redirect_to @manager, notice: 'Manager successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @manager.update(manager_params)
      redirect_to @manager, notice: 'Manager successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @manager.destroy
    redirect_to managers_path, notice: 'Manager successfully deleted.'
  end

  def assign_locker
    if @manager.lockers.count >= 4
      redirect_to manager_path(@manager), alert: 'This manager cannot have more than 4 lockers.'
      return
    end
    
    if params[:locker_id].blank?
      redirect_to manager_path(@manager), alert: 'Please select a locker to assign.'
      return
    end
  
    begin
      locker = Locker.find(params[:locker_id])
      locker.update!(manager: @manager)
      redirect_to manager_path(@manager), notice: 'Locker successfully assigned.'
    rescue ActiveRecord::RecordNotFound
      redirect_to manager_path(@manager), alert: 'The selected locker does not exist.'
    rescue StandardError => e
      redirect_to manager_path(@manager), alert: "An error occurred: #{e.message}"
    end
  end
  

  def unassign_locker
    locker = Locker.find(params[:locker_id])
    locker.update(manager: nil)

    redirect_to manager_path(params[:id]), notice: 'Locker successfully unassigned.'
  end

  def synchronize
    if @manager.lockers.empty?
      redirect_to manager_path(@manager), alert: 'No lockers associated with the manager for synchronization.'
      return
    end

    locker_count = @manager.lockers.count
    

    topic = "sincronizar"
    message = build_sync_message(@manager)

    begin
      locker_count = @manager.lockers.count
      MQTT_CLIENT.publish(topic, message.to_json)
      Rails.logger.info("Synchronization message sent to topic #{topic}: #{message}")
      redirect_to manager_path(@manager), notice: "Information synchronized with ESP32, this controller has #{locker_count} lockers assigned."
    rescue StandardError => e
      Rails.logger.error("Error during synchronization: #{e.message}")
      redirect_to manager_path(@manager), alert: "Error during synchronization: #{e.message}"
    end
  end

  def synchronize_manager(manager)
    if manager.lockers.empty?
      Rails.logger.warn("Manager #{manager.id} has no lockers for synchronization.")
      return false
    end
  
    topic = "sincronizar"
    message = build_sync_message(manager)
  
    begin
      MQTT_CLIENT.publish(topic, message.to_json)
      Rails.logger.info("Synchronization message sent to topic #{topic}: #{message}")
      return true
    rescue StandardError => e
      Rails.logger.error("Error during synchronization for manager #{manager.id}: #{e.message}")
      return false
    end
  end

  def check_connection
    manager = Manager.find(params[:id])
    topic = "conectado"
    message = { mac: manager.mac_address, question: "connected?", mode: "manual" }
  
    begin
      MQTT_CLIENT.publish(topic, message.to_json)
      Rails.logger.info("Mensaje enviado a #{topic}: #{message}")
      flash[:notice] = "Mensaje de conexión enviado correctamente."
    rescue StandardError => e
      Rails.logger.error("Error al enviar mensaje de conexión: #{e.message}")
      flash[:alert] = "Error al verificar conexión: #{e.message}"
    end
  
    redirect_to manager_path(manager)
  end
  
  def check_flash
    manager_id = params[:id]
    flash_message = Rails.cache.read("manager_#{manager_id}_flash")
    if flash_message
      Rails.cache.delete("manager_#{manager_id}_flash")
      render json: { flash: flash_message }
    else
      render json: { flash: nil }
    end
  end
  
  
  

  private

  def build_sync_message(manager)
    lockers_data = manager.lockers.map do |locker|
      {
        id: locker.id,
        password: locker.password
      }
    end

    message = {
      mac: manager.mac_address,
      id: manager.id,
      predictor_id: manager.predictor.id,
      lockers: lockers_data
    }

    if manager.predictor&.txt_file&.attached?
      file_content = manager.predictor.txt_file.download
      message[:txt_file] = Base64.encode64(file_content)
    else
      message[:txt_file] = nil
    end

    message
  end


  def authorize_user!
    unless @manager.user_id == current_user.id
      redirect_to managers_path, alert: 'You do not have permission to view or edit this manager.'
    end
  end

  def set_manager
    @manager = Manager.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to managers_path, alert: "Manager not found."
  end

  def manager_params
    params.require(:manager).permit(:name, :active_lockers, :predictor_id)
  end
end
