class MetricsController < ApplicationController
  def index
    @lockers = current_user.lockers # Obtener casilleros asociados al usuario actual
  
    # Aperturas total por locker (desde la tabla `openings`)
    @openings_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.openings.count
    end
  
    # Intentos fallidos total por locker
    @failed_attempts_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.failed_attempts_count || 0 # Cambiar si los intentos fallidos se registran por eventos
    end
  
    # Cambios de contraseña total por locker
    @password_changes_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.password_changes_count || 0 # Cambiar si los cambios de contraseña se registran por eventos
    end
  
    # Aperturas por locker en la última semana
    start_of_week = Time.current.beginning_of_week
    end_of_week = Time.current.end_of_week
    @weekly_openings_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.openings.where(opened_at: start_of_week..end_of_week).count
    end

    # Última apertura por locker
    @last_opened_at_per_locker = @lockers.each_with_object({}) do |locker, hash|
      last_opening = locker.openings.order(opened_at: :desc).first
      hash[locker.id] = last_opening&.opened_at
    end
  
    # Total de aperturas semanales
    @total_weekly_openings = @weekly_openings_per_locker.values.sum
  
    # Tasa de éxito de aperturas
    @success_rate_openings = calculate_success_rate_openings
  
    # Casilleros abiertos
    @open_lockers = @lockers.where(opening: true).count
  
    # Locker más abierto
    most_opened_locker_id = @openings_per_locker.max_by { |_id, count| count }&.first
    @most_opened_locker = @lockers.find { |locker| locker.id == most_opened_locker_id }
  
    # Locker con más intentos fallidos
    most_failed_attempts_locker_id = @failed_attempts_per_locker.max_by { |_id, count| count }&.first
    @most_failed_attempts_locker = @lockers.find { |locker| locker.id == most_failed_attempts_locker_id }

    #calculate_daily_openings
    calculate_daily_openings
    
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
      redirect_to @metric, notice: 'Metric successfully created.'
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
      redirect_to @metric, notice: 'Metric successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @metric = Metric.find(params[:id])
    @metric.destroy
    redirect_to metrics_path, notice: 'Metric successfully deleted.'
  end

  private

  def metric_params
    params.require(:metric).permit(:openings_count, :failed_attempts_count, :password_changes_count)
  end

  def calculate_success_rate_openings
    total_openings = @openings_per_locker.values.sum
    total_attempts = total_openings + @failed_attempts_per_locker.values.sum
    total_attempts.positive? ? (total_openings / total_attempts.to_f * 100).round(2) : 0
  end

  def calculate_daily_openings
    start_date = 7.days.ago.to_date
    end_date = Date.today
  
    # Inicializa las fechas con valores en 0
    @daily_openings = (start_date..end_date).map { |date| [date, 0] }.to_h
  
    # Obtén los conteos reales
    actual_openings = Opening
      .where(opened_at: start_date.beginning_of_day..end_date.end_of_day)
      .group("DATE(opened_at)")
      .count
  
    # Combina los valores reales con los inicializados
    @daily_openings.merge!(actual_openings) { |_key, old_val, new_val| old_val + new_val }
  end
  
  
end
