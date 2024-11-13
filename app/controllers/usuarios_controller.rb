class UsuariosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]
  before_action :authorize_super_user, only: [:index, :destroy]
  before_action :authorize_user_or_super_user!, only: [:edit, :update]

  def index
    @usuarios = Usuario.all
  end

  def show
    @usuario = Usuario.find(params[:id])
    @casilleros = @usuario.casilleros
    @controladores = @usuario.controladores
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
    @modelos = Modelo.all
  end

  def update
    @usuario = Usuario.find(params[:id])
    
    # Asigna el valor actual de `username` si el campo está vacío
    usuario_params[:username] = @usuario.username if usuario_params[:username].blank?
    
    if @usuario.update(usuario_params)
      flash[:notice] = 'Perfil actualizado exitosamente.'
      redirect_to usuarios_path
    else
      @modelos = Modelo.all
      flash[:alert] = 'Hubo un problema al actualizar el perfil.'
      render :edit
    end
  end
  
  def destroy
    if @usuario.super_user?
      redirect_to usuarios_path, alert: "No puedes eliminar un superusuario."
    else
      @usuario.destroy
      redirect_to usuarios_path, notice: 'Usuario eliminado exitosamente.'
    end
  end

  private

  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  def authorize_super_user
    redirect_to(authenticated_root_path, alert: 'No tienes permiso para acceder a esta página.') unless current_usuario.super_user?
  end  

  def authorize_user_or_super_user!
    unless current_usuario == @usuario || current_usuario.super_user?
      redirect_to(root_path, alert: 'No tienes permiso para editar este perfil.')
    end
  end

  def usuario_params
    params.require(:usuario).permit(:username, :first_name, :last_name, :modelo_id)
  end
end
