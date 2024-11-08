class UsuariosController < ApplicationController
  before_action :authenticate_usuario! 
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]

  def index
    @usuarios = Usuario.all
  end

  def show
    @usuario = Usuario.find(params[:id])
  end

  def registro
    @usuario = Usuario.new
    @modelos = Modelo.all 
  end

  def create
    @usuario = Usuario.new(usuario_params)
    if @usuario.save
      redirect_to root_path, notice: 'Usuario registrado exitosamente.'
    else
      @modelos = Modelo.all
      render :registro
    end
  end

  def edit
    @usuario = current_usuario
  end

  def update
    @usuario = current_usuario
    if @usuario.update(usuario_params)
      flash[:notice] = 'Perfil actualizado exitosamente.'
      redirect_to controladores_path
    else
      flash[:alert] = 'Hubo un problema al actualizar el perfil.'
      render :edit
    end
  end

  def destroy
    @usuario = Usuario.find(params[:id])
    @usuario.destroy
    redirect_to usuarios_path, notice: 'Usuario eliminado exitosamente.'
  end
  
  private

  def set_usuario
    @usuario = current_usuario
  end

  def usuario_params
    params.require(:usuario).permit(:mail, :username, :first_name, :last_name, :password, :modelo_id)
  end
end
