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
      redirect_to predictors_path, notice: 'Predictor successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @predictor.update(predictor_params)
      redirect_to @predictor, notice: 'Predictor successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @predictor = Predictor.find(params[:id])

    # Desvincular usuarios relacionados
    User.where(predictor_id: @predictor.id).update_all(predictor_id: nil)

    # Desvincular managers relacionados
    Manager.where(predictor_id: @predictor.id).update_all(predictor_id: nil)

    if @predictor.destroy
      redirect_to predictors_path, notice: 'Predictor and its associations successfully cleaned and deleted.'
    else
      redirect_to predictors_path, alert: 'Failed to delete predictor.'
    end
  end

  private

  def set_predictor
    @predictor = Predictor.find(params[:id])
  end

  def predictor_params
    params.require(:predictor).permit(
      :name,
      :txt_file,
      signs_attributes: [:id, :sign_name, :image, :_destroy]
    )
  end

  def authorize_super_user
    redirect_to(root_path, alert: "You do not have permission to access this page.") unless current_user&.super_user?
  end
end
