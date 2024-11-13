class ManagersController < ApplicationController
  before_action :set_manager, only: [:show, :edit, :update, :destroy]

  def index
    @managers = Manager.all
  end

  def show
    @manager = Manager.find(params[:id])
  end

  def new
    @manager = Manager.new
  end

  def create
    @manager = Manager.new(manager_params)
    if @manager.save
      redirect_to @manager, notice: 'Manager creado exitosamente.'
    else
      render :new
    end
  end

  def edit
    @manager = Manager.find(params[:id])
  end

  def update
    @manager = Manager.find(params[:id])
    if @manager.update(manager_params)
      redirect_to @manager, notice: 'Manager actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @manager = Manager.find(params[:id])
    @manager.destroy
    redirect_to managers_path, notice: 'Manager eliminado exitosamente.'
  end

  private

  def set_manager
    @manager = Manager.find(params[:manager_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to managers_path, alert: "Manager no encontrado."
  end  

  def manager_params
    params.require(:manager).permit(:name, :active_lockers, :user_id, :predictor_id)
  end
end
