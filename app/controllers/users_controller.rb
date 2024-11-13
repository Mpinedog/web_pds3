class UsersController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def register
    @user = User.new
    @predictors = Predictor.all 
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: 'User registrado exitosamente.'
    else
      @predictors = Predictor.all
      render :register
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:notice] = 'Perfil actualizado exitosamente.'
      redirect_to managers_path
    else
      flash[:alert] = 'Hubo un problema al actualizar el perfil.'
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: 'User eliminado exitosamente.'
  end
  
  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:mail, :username, :first_name, :last_name, :password, :predictor_id)
  end
end
