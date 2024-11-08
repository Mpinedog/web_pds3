class CasillerosController < ApplicationController
  before_action :set_controlador, only: [:show, :edit, :update, :destroy, :sincronizar]

  def index
    @casilleros = Casillero.all
  end

  def show
    @casilleros = @controlador.casilleros || [] 
  end

  def new
    @casillero = Casillero.new
  end

  def create
    @casillero = @controlador.casilleros.build(casillero_params)
    if @casillero.save
      redirect_to controlador_path(@controlador), notice: 'Casillero agregado exitosamente.'
    else
      render :new
    end
  end

  def edit
    @casillero = Casillero.find(params[:id])
  end

  def update
    @casillero = Casillero.find(params[:id])
    if @casillero.update(casillero_params)
      redirect_to @casillero, notice: 'Casillero actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @casillero = Casillero.find(params[:id])
    @casillero.destroy
    redirect_to casilleros_path, notice: 'Casillero eliminado exitosamente.'
  end

  def set_controlador
    @controlador = Controlador.find(params[:id])
  end

  private

  def casillero_params
    params.require(:controlador).permit(:nombre, :casilleros_activos, :usuario_id, :modelo_id)
  end
end
