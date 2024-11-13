class PredictorsController < ApplicationController
  before_action :authenticate_user! 
  before_action :authorize_super_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_predictor, only: [:show, :edit, :update, :destroy]

  def index
    @predictors = Predictor.all
  end

  def show
  end

  def new
    @predictor = Predictor.new
    6.times { @predictor.signs.build } 
  end

  def create
    @predictor = Predictor.new(predictor_params)
    if @predictor.save
      redirect_to predictors_path, notice: 'Predictor creado exitosamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @predictor.update(predictor_params)
      redirect_to @predictor, notice: 'Predictor actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @predictor.destroy
    redirect_to predictors_path, notice: 'Predictor eliminado exitosamente.'
  end

  private

  def set_predictor
    @predictor = Predictor.find(params[:id])
  end

  def predictor_params
    params.require(:predictor).permit(
      :tflite_file, 
      signs_attributes: [:id, :sign_name, :image, :_destroy]
    )
  end

  def authorize_super_user
    redirect_to(root_path, alert: "No tienes permiso para acceder a esta página.") unless current_user&.super_user?
  end
end
