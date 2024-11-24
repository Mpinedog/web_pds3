class ManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_manager, only: [:show, :edit, :update, :destroy, :assign_locker, :synchronize]
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
    locker = Locker.find(params[:locker_id])
    locker.update(manager: @manager)

    redirect_to manager_path(@manager), notice: 'Locker successfully assigned.'
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

    topic = "sincronizar"
    message = build_sync_message(@manager)

    begin
      MQTT_CLIENT.publish(topic, message.to_json)
      Rails.logger.info("Synchronization message sent to topic #{topic}: #{message}")
      redirect_to manager_path(@manager), notice: 'Information synchronized with ESP32.'
    rescue StandardError => e
      Rails.logger.error("Error during synchronization: #{e.message}")
      redirect_to manager_path(@manager), alert: "Error during synchronization: #{e.message}"
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