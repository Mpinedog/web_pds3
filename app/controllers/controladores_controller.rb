class ControladoresController < ApplicationController
  before_action :set_controlador, only: [:show, :edit, :update, :destroy]

  def index
    @controladores = Controlador.all
  end

  def show
    @controlador = Controlador.find(params[:id])
  end

  def new
    @controlador = Controlador.new
  end

  def create
    @controlador = Controlador.new(controlador_params)
    if @controlador.save
      redirect_to @controlador, notice: 'Controlador creado exitosamente.'
    else
      render :new
    end
  end

  def edit
    @controlador = Controlador.find(params[:id])
  end

  def update
    @controlador = Controlador.find(params[:id])
    if @controlador.update(controlador_params)
      redirect_to @controlador, notice: 'Controlador actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @controlador = Controlador.find(params[:id])
    @controlador.destroy
    redirect_to controladores_path, notice: 'Controlador eliminado exitosamente.'
  end

  private

  def set_controlador
    @controlador = Controlador.find(params[:controlador_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to controladores_path, alert: "Controlador no encontrado."
  end  

  def controlador_params
    params.require(:controlador).permit(:nombre, :casilleros_activos, :usuario_id, :modelo_id)
  end
end
