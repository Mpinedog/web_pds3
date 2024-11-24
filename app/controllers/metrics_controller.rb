class MetricsController < ApplicationController
  def index
    @lockers = Locker.includes(:metric)

    @openings_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.openings_count || 0
    end

    @failed_attempts_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.failed_attempts_count || 0
    end

    @password_changes_per_locker = @lockers.each_with_object({}) do |locker, hash|
      hash[locker.id] = locker.metric&.password_changes_count || 0
    end

    @success_rate_openings = calculate_success_rate_openings
    @open_lockers = @lockers.where(opening: true).count
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
    total_openings = @lockers.sum { |locker| locker.metric&.openings_count.to_i }
    total_attempts = total_openings + @lockers.sum { |locker| locker.metric&.failed_attempts_count.to_i }
    total_attempts > 0 ? (total_openings / total_attempts.to_f * 100).round(2) : 0
  end
end