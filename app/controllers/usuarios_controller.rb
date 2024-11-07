class UsuariosController < ApplicationController
  def index
    @usuarios = Usuario.all
  end

  def show
    @usuario = Usuario.find(params[:id])
  end

  def registro
    @usuario = Usuario.new
    @modelos = Modelo.all # Lista de modelos para el formulario
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
    @usuario = Usuario.find(params[:id])
  end

  def update
    @usuario = Usuario.find(params[:id])
    if @usuario.update(usuario_params)
      redirect_to @usuario, notice: 'Usuario actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @usuario = Usuario.find(params[:id])
    @usuario.destroy
    redirect_to usuarios_path, notice: 'Usuario eliminado exitosamente.'
  end

  private

  def usuario_params
    params.require(:usuario).permit(:mail, :username, :first_name, :last_name, :password, :modelo_id)
  end
end
