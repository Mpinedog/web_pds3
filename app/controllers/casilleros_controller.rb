class CasillerosController < ApplicationController
  def index
    @casilleros = Casillero.all
  end

  def show
    @casillero = Casillero.find(params[:id])
  end

  def new
    @casillero = Casillero.new
  end

  def create
    @casillero = Casillero.new(casillero_params)
    if @casillero.save
      redirect_to @casillero, notice: 'Casillero creado exitosamente.'
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

  private

  def casillero_params
    params.require(:casillero).permit(:apertura, :clave, :usuario_id, :controlador_id, :metrica_id)
  end
end
