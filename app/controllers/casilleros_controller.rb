class CasillerosController < ApplicationController
  before_action :set_controlador, only: [:index, :show, :edit, :update, :destroy]
  before_action :authenticate_usuario!

  def index
    @casilleros = Casillero.all
  end

  def show
    @casilleros = @controlador.casilleros || [] 
  end

  def new
    @casillero = @controlador.casilleros.build
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
    @controlador = Controlador.find(params[:controlador_id])
  end  

  private

  def casillero_params
    params.require(:casillero).permit(:nombre, :estado)
  end

  def generar_contrasena
    @casillero = Casillero.find(params[:id])
    @casillero.contrasena = SecureRandom.hex(4)  
    
    if @casillero.save
      redirect_to authenticated_root_path, notice: "Contraseña del casillero #{@casillero.id} actualizada con éxito."
    else
      redirect_to authenticated_root_path, alert: "Hubo un error al actaulizar la contraseña del casillero."
    end
  end
end
