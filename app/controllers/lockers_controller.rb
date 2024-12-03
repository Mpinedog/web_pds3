class LockersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_manager, if: -> { params[:manager_id].present? }
  before_action :set_locker, only: [:show, :edit, :update, :destroy]
  before_action :authorize_manager_owner, only: [:edit, :update, :destroy]


  def index
    @lockers = Locker.all
  end

  def show
    @locker = Locker.find(params[:id])
    @openings = @locker.openings.order(opened_at: :desc)
  end

  def new
    @locker = @manager ? @manager.lockers.build : Locker.new
  end

  def create
    @locker = @manager ? @manager.lockers.build(locker_params.except(:owner_email)) : Locker.new(locker_params.except(:owner_email))

    assign_user_by_email(locker_params[:owner_email]) # Asigna el usuario basado en el correo

    @locker.metric ||= Metric.create(openings_count: 0, failed_attempts_count: 0, password_changes_count: 0)

    if @locker.save
      LockerMailer.notify_owner(@locker).deliver_now
      redirect_to locker_path(@locker), notice: 'Locker successfully added.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    assign_user_by_email(locker_params[:owner_email])

    # Verificar si la contraseña ha cambiado
    if locker_params[:password].present? && locker_params[:password] != @locker.password
      @locker.metric.increment!(:password_changes_count)
      Rails.logger.info("Locker #{@locker.id}: Password change recorded. Total changes: #{@locker.metric.password_changes_count}")
    end
  
    if @locker.update(locker_params.except(:owner_email))
      user = @locker.user # Obtén el usuario asociado al locker
      if user.present?
        send_predictor_mail(@locker.manager.predictor_id, user, @locker)
      else
        Rails.logger.warn("No user associated with Locker #{@locker.id}. Email not sent.")
      end
      redirect_to locker_path(@locker), notice: 'Locker successfully updated and notification sent to the owner.'
    else
      render :edit
    end
  end  

  def destroy
    @locker.destroy
    redirect_to lockers_path, notice: 'Locker successfully deleted.'
  end

  private

  def set_locker
    @locker = Locker.find(params[:id])
  end

  def set_manager
    @manager = Manager.find(params[:manager_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to managers_path, alert: "Manager not found."
  end

  def assign_user_by_email(email)
    if email.present?
      user = User.find_by(email: email)
      if user
        @locker.user = user
      else
        @locker.errors.add(:owner_email, 'No user found with that email address')
      end
    end
  end

  def locker_params
    params.require(:locker).permit(:name, :password, :manager_id, :owner_email)
  end

  def authorize_manager_owner
    unless @locker.manager.user_id == current_user.id
      redirect_to lockers_path, alert: 'You do not have permission to edit or delete this locker.'
    end
  end

  def send_predictor_mail(predictor_id, user, locker)
    case predictor_id
    when 1
      ManagerMailer.predictor_one_email(user, locker).deliver_now
      Rails.logger.info("Email for Predictor 1 sent to User #{user.id} for Locker #{locker.id}.")
    when 2
      ManagerMailer.predictor_two_email(user, locker).deliver_now
      Rails.logger.info("Email for Predictor 2 sent to User #{user.id} for Locker #{locker.id}.")
    else
      ManagerMailer.predictor_one_email(user, locker).deliver_now
      Rails.logger.info("Email for Predictor 1 sent to User #{user.id} for Locker #{locker.id}.")
    end
  end
end
