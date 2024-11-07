class MetricasController < ApplicationController
  def index
    @metricas = Metrica.all
  end

  def show
    @metrica = Metrica.find(params[:id])
  end

  def new
    @metrica = Metrica.new
  end

  def create
    @metrica = Metrica.new(metrica_params)
    if @metrica.save
      redirect_to @metrica, notice: 'Métrica creada exitosamente.'
    else
      render :new
    end
  end

  def edit
    @metrica = Metrica.find(params[:id])
  end

  def update
    @metrica = Metrica.find(params[:id])
    if @metrica.update(metrica_params)
      redirect_to @metrica, notice: 'Métrica actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @metrica = Metrica.find(params[:id])
    @metrica.destroy
    redirect_to metricas_path, notice: 'Métrica eliminada exitosamente.'
  end

  private

  def metrica_params
    params.require(:metrica).permit(:cant_aperturas, :cant_intentos_fallidos, :cant_cambios_contrasena)
  end
end
