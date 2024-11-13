class ModelosController < ApplicationController
  before_action :authenticate_usuario! 
  before_action :authorize_super_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_modelo, only: [:show, :edit, :update, :destroy]

  def index
    @modelos = Modelo.all
  end

  def show
  end

  def new
    @modelo = Modelo.new
    6.times { @modelo.signs.build } 
  end

  def create
    @modelo = Modelo.new(modelo_params)
    if @modelo.save
      redirect_to modelos_path, notice: 'Modelo creado exitosamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @modelo.update(modelo_params)
      redirect_to @modelo, notice: 'Modelo actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @modelo.destroy
    redirect_to modelos_path, notice: 'Modelo eliminado exitosamente.'
  end

  private

  def set_modelo
    @modelo = Modelo.find(params[:id])
  end

  def modelo_params
    params.require(:modelo).permit(
      :nombre,
      :txt_file, 
      signs_attributes: [:id, :sign_name, :image, :_destroy]
    )
  end

  def authorize_super_user
    redirect_to(root_path, alert: "No tienes permiso para acceder a esta página.") unless current_usuario&.super_user?
  end
end
