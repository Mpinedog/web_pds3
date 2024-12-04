class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_super_user, only: [:index, :destroy]
  before_action :authorize_user_or_super_user!, only: [:edit, :update]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @lockers = @user.lockers
    @managers = @user.managers
  end  

  def register
    @user = User.new
    @predictors = Predictor.all
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: 'User successfully registered.'
    else
      @predictors = Predictor.all
      render :register
    end
  end

  def edit
    @predictors = Predictor.all
  end

  def update
    if @user.update(user_params)
      # Sincronizar managers relacionados
      @user.managers.each do |manager|
        result = ManagersController.new.synchronize_manager(manager)
        unless result
          Rails.logger.warn("Manager #{manager.id} failed to synchronize after user predictor update.")
        end
      end
      flash[:notice] = "User and related managers updated successfully."
      redirect_to users_path
    else
      flash[:alert] = "Error updating user."
      render :edit
    end
  end
  
  
  def destroy
    if @user.super_user?
      redirect_to users_path, alert: "You cannot delete a superuser."
    else
      @user.update(predictor_id: nil) # Remover predictor asociado si existe
      @user.managers.update_all(user_id: nil) # Desasociar managers si los tiene
      @user.lockers.update_all(user_id: nil)  # Desasociar lockers si los tiene
      @user.destroy
      redirect_to users_path, notice: 'User successfully deleted.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_super_user
    redirect_to(authenticated_root_path) unless current_user.super_user?
  end  

  def authorize_user_or_super_user!
    unless current_user == @user || current_user.super_user?
      redirect_to(authenticated_root_path, alert: 'You do not have permission to edit this profile.')
    end
  end

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :predictor_id)
  end
end
