class ModelosController < ApplicationController
  def index
    @modelos = Modelo.all
  end

  def show
    @modelo = Modelo.find(params[:id])
  end

  def new
    @modelo = Modelo.new
  end

  def create
    @modelo = Modelo.new(modelo_params)
    if @modelo.save
      redirect_to @modelo, notice: 'Modelo creado exitosamente.'
    else
      render :new
    end
  end

  def edit
    @modelo = Modelo.find(params[:id])
  end

  def update
    @modelo = Modelo.find(params[:id])
    if @modelo.update(modelo_params)
      redirect_to @modelo, notice: 'Modelo actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @modelo = Modelo.find(params[:id])
    @modelo.destroy
    redirect_to modelos_path, notice: 'Modelo eliminado exitosamente.'
  end

  private

  def modelo_params
    params.require(:modelo).permit(:sign1, :sign2, :sign3, :sign4, :sign5, :sign6)
  end
end
