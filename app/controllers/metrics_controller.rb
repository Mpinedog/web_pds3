class MetricsController < ApplicationController
  def index
    @lockers = Locker.includes(:metric) 

    @openings_por_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.openings || 0
    end

    @intentos_fallidos_por_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.failed_attemps || 0
    end

    @cambios_contrasena_por_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.password_changes || 0
    end

    @porcentaje_exito_openings = calcular_porcentaje_exito_openings
    @lockers_abiertos = @lockers.where(opening: true).count
  end

  def show
    @metric = Metric.find(params[:id])
  end

  def new
    @metric = Metric.new
  end

  def create
    @metric = Metric.new(metric_params)
    if @metric.save
      redirect_to @metric, notice: 'Métrica creada exitosamente.'
    else
      render :new
    end
  end

  def edit
    @metric = Metric.find(params[:id])
  end

  def update
    @metric = Metric.find(params[:id])
    if @metric.update(metric_params)
      redirect_to @metric, notice: 'Métrica actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @metric = Metric.find(params[:id])
    @metric.destroy
    redirect_to metrics_path, notice: 'Métrica eliminada exitosamente.'
  end

  private

  def metric_params
    params.require(:metric).permit(:openings, :failed_attemps, :password_changes)
  end


  # def calcular_openings_promedio_por_dia
  #   total_openings = @lockers.sum { |locker| locker.metrics&.openings.to_i }
  #   dias_desde_primer_opening = (Date.today - @lockers.minimum(:created_at).to_date).to_i
  #   dias_desde_primer_opening > 0 ? (total_openings / dias_desde_primer_opening.to_f).round(2) : 0
  # end

  def calcular_porcentaje_exito_openings
    total_openings = @lockers.sum { |locker| locker.metrics&.openings.to_i }
    total_intentos = total_openings + @lockers.sum { |locker| locker.metrics&.failed_attemps.to_i }
    total_intentos > 0 ? (total_openings / total_intentos.to_f * 100).round(2) : 0
  end
end