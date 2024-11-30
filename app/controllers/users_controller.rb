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
    @user = User.find(params[:id])
    
    # Assign current `username` value if the field is blank
    user_params[:username] = @user.username if user_params[:username].blank?
    
    if @user.update(user_params)
      flash[:notice] = 'Profile successfully updated.'
      redirect_to users_path
    else
      @predictors = Predictor.all
      flash[:alert] = 'There was a problem updating the profile.'
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
    redirect_to(authenticated_root_path, alert: 'You do not have permission to access this page.') unless current_user.super_user?
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
