class LockersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_manager, only: [:show, :new, :create, :edit, :update, :destroy], if: -> { params[:manager_id].present? }

  def index
    @lockers = Locker.all
  end

  def show
    @locker = Locker.find(params[:id])
  end

  def new
    @locker = @manager ? @manager.lockers.build : Locker.new
  end

  def create
    @locker = @manager ? @manager.lockers.build(locker_params.except(:owner_email)) : Locker.new(locker_params.except(:owner_email))
    
    user_email = locker_params[:owner_email]
    @locker.user = User.find_by(email: user_email) if user_email.present?

    @locker.metric ||= Metric.create(openings: 0, failed_attemps: 0, password_changes: 0)

    if @locker.save
      LockerMailer.notificate_owner(@locker).deliver_now
      redirect_to locker_path(@locker), notice: 'Locker agregado exitosamente.'
    else
      render :new
    end
  end
  
  def edit
    @locker = Locker.find(params[:id])
  end

  def update
    @locker = Locker.find(params[:id])
    assign_user_to_locker

    if @locker.update(locker_params)
      send_mail_locker(@locker)
      redirect_to locker_path(@locker), notice: 'Locker actualizado exitosamente y notificación enviada al dueño.'
    else
      render :edit
    end
  end

  def destroy
    @locker = Locker.find(params[:id])
    @locker.destroy
    redirect_to lockers_path, notice: 'Locker eliminado exitosamente.'
  end

  private

  def assign_user_to_locker
    email = params[:locker][:owner_email]
    @locker.user = User.find_by(email: email)
    unless @locker.user
      @locker.errors.add(:owner_email, 'No se encontró un user con ese correo electrónico')
    end
  end

  def send_mail_locker(locker)
    LockerMailer.with(locker: locker).notificate_owner.deliver_now
  end

  def locker_params
    params.require(:locker).permit(:opening, :password, :user_id, :manager_id, :owner_email)
  end  

  def set_manager
    @manager = Manager.find(params[:manager_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to managers_path, alert: "Manager no encontrado."
  end
end
