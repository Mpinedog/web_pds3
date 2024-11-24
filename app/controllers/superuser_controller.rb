class SuperuserController < ApplicationController
    def index
      @user_count = User.count
  
      @lockers = Locker.includes(:metric)
  
      @manager_count = Manager.count
  
      @openings_per_locker = @lockers.each_with_object({}) do |locker, hash|
        hash[locker.id] = locker.metric&.openings_count || 0
      end
  
      @failed_attempts_per_locker = @lockers.each_with_object({}) do |locker, hash|
        hash[locker.id] = locker.metric&.failed_attempts_count || 0
      end
  
      @password_changes_per_locker = @lockers.each_with_object({}) do |locker, hash|
        hash[locker.id] = locker.metric&.password_changes_count || 0
      end
  
      @total_password_changes = @lockers.sum do |locker|
        locker.metric&.password_changes_count || 0
      end
  
      @success_rate_openings = calculate_success_rate_openings
      @open_lockers = @lockers.where(opening: true).count
    end
  
    def calculate_success_rate_openings
      total_openings = @lockers.sum { |locker| locker.metric&.openings_count.to_i }
      total_attempts = total_openings + @lockers.sum { |locker| locker.metric&.failed_attempts_count.to_i }
      total_attempts > 0 ? (total_openings / total_attempts.to_f * 100).round(2) : 0
    end
  end
  