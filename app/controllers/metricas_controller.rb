class MetricasController < ApplicationController
  def index
    @casilleros = Casillero.includes(:metrica) 

    @aperturas_por_casillero = @casilleros.each_with_object({}) do |casillero, hash|
      hash[casillero.id] = casillero.metrica&.cant_aperturas || 0
    end

    @intentos_fallidos_por_casillero = @casilleros.each_with_object({}) do |casillero, hash|
      hash[casillero.id] = casillero.metrica&.cant_intentos_fallidos || 0
    end

    @cambios_contrasena_por_casillero = @casilleros.each_with_object({}) do |casillero, hash|
      hash[casillero.id] = casillero.metrica&.cant_cambios_contrasena || 0
    end

    @porcentaje_exito_aperturas = calcular_porcentaje_exito_aperturas
    @casilleros_abiertos = @casilleros.where(apertura: true).count
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


  # def calcular_aperturas_promedio_por_dia
  #   total_aperturas = @casilleros.sum { |casillero| casillero.metricas&.cant_aperturas.to_i }
  #   dias_desde_primer_apertura = (Date.today - @casilleros.minimum(:created_at).to_date).to_i
  #   dias_desde_primer_apertura > 0 ? (total_aperturas / dias_desde_primer_apertura.to_f).round(2) : 0
  # end

  def calcular_porcentaje_exito_aperturas
    total_aperturas = @casilleros.sum { |casillero| casillero.metricas&.cant_aperturas.to_i }
    total_intentos = total_aperturas + @casilleros.sum { |casillero| casillero.metricas&.cant_intentos_fallidos.to_i }
    total_intentos > 0 ? (total_aperturas / total_intentos.to_f * 100).round(2) : 0
  end
end