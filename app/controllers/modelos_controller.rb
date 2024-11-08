class ModelosController < ApplicationController
  before_action :set_modelo, only: [:show, :edit, :update, :destroy]

  def index
    @modelos = Modelo.all
  end

  def show
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
  end

  def update
    if @modelo.update(modelo_params)
      redirect_to @modelo, notice: 'Modelo actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @modelo.destroy
    redirect_to modelos_path, notice: 'Modelo eliminado exitosamente.'
  end

  private

  def set_modelo
    @modelo = Modelo.find(params[:id])
  end

  def modelo_params
    params.require(:modelo).permit(:sign1, :sign2, :sign3, :sign4, :sign5, :sign6, archivos: [], figuras: [])
  end
end
