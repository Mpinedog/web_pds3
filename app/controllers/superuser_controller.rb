class SuperuserController < ApplicationController
  def index
    @user_count = User.count
    @manager_count = Manager.count
    @active_managers_count = Manager.where(active: true).count
    @active_lockers_count = Locker.joins(:manager).where(managers: { active: true }).where(opening: true).count


    # Cargar todos los lockers con sus métricas y aperturas
    @lockers = Locker.includes(:metric, :openings)

    # Aperturas totales por locker (desde la tabla `openings`)
    @openings_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.openings.count
    end

    # Intentos fallidos totales por locker
    @failed_attempts_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.failed_attempts_count || 0
    end

    # Cambios de contraseña totales por locker
    @password_changes_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.password_changes_count || 0
    end

    # Aperturas por locker en la última semana
    start_of_week = Time.current.beginning_of_week
    end_of_week = Time.current.end_of_week
    @weekly_openings_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.openings.where(opened_at: start_of_week..end_of_week).count
    end

    # Aperturas por día para cada locker
    start_of_day = Time.current.beginning_of_day
    end_of_day = Time.current.end_of_day

    @daily_openings_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.openings.where(opened_at: start_of_day..end_of_day).count
    end

    # Total de aperturas en el día
    @daily_openings = @daily_openings_per_locker.values.sum


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

    # Total de aperturas en la última semana
    @total_weekly_openings = @weekly_openings_per_locker.values.sum

    # Locker más abierto en la última semana
    most_weekly_opened_locker_id = @weekly_openings_per_locker.max_by { |_id, count| count }&.first
    @most_weekly_opened_locker = @lockers.find { |locker| locker.id == most_weekly_opened_locker_id }

  end

  private

  def calculate_success_rate_openings
    total_openings = @openings_per_locker.values.sum
    total_attempts = total_openings + @failed_attempts_per_locker.values.sum
    total_attempts.positive? ? (total_openings / total_attempts.to_f * 100).round(2) : 0
  end
end
