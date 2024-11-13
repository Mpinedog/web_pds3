class ControladoresController < ApplicationController
  before_action :authenticate_usuario! 
  before_action :set_controlador, only: [:show, :edit, :update, :destroy, :asignar_casillero, :sincronizar ]
  before_action :authorize_user!, only: [:show, :edit, :update, :destroy, :asignar_casillero]
  require 'base64'

  def index
    @controladores = current_usuario.controladores
  end

  def show
    @casilleros_disponibles = Casillero.where(controlador_id: nil)
  end

  def new
    @controlador = Controlador.new
  end

  def create
    @controlador = current_usuario.controladores.build(controlador_params) 
    if @controlador.save
      redirect_to @controlador, notice: 'Controlador creado exitosamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @controlador.update(controlador_params)
      redirect_to @controlador, notice: 'Controlador actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @controlador.destroy
    redirect_to controladores_path, notice: 'Controlador eliminado exitosamente.'
  end

  def asignar_casillero
    casillero = Casillero.find(params[:casillero_id])
    casillero.update(controlador: @controlador)

    redirect_to controlador_path(@controlador), notice: 'Casillero asignado exitosamente.'
  end

  def desasignar_casillero
    casillero = Casillero.find(params[:casillero_id])
    casillero.update(controlador: nil)

    redirect_to controlador_path(params[:id]), notice: 'Casillero desasignado exitosamente.'
  end

  def sincronizar
    topic = "sincronizar"
  
    # Construye el mensaje JSON con los datos del controlador
    mensaje = {
      id: @controlador.id,
      modelo_id: @controlador.modelo_id,
      casilleros: @controlador.casilleros.map { |casillero| { id: casillero.id, clave: casillero.clave } }
    }
  
    if @controlador.modelo&.txt_file&.attached?
      contenido_archivo = @controlador.modelo.txt_file.download
      contenido_base64 = Base64.encode64(contenido_archivo)
      mensaje[:archivo_txt] = contenido_base64  # Agrega el archivo codificado al mensaje
    else
      mensaje[:archivo_txt] = nil  # Envía nil si no hay archivo adjunto
    end
  
    # Publica el mensaje JSON al broker MQTT de HiveMQ
    MQTT_CLIENT.publish(topic, mensaje.to_json)
  
    redirect_to controlador_path(@controlador), notice: 'Información sincronizada con el ESP32'
  rescue => e
    redirect_to controlador_path(@controlador), alert: "Error al sincronizar: #{e.message}"
  end


  private

  def authorize_user!
    unless @controlador.usuario_id == current_usuario.id
      redirect_to controladores_path, alert: 'No tienes permiso para ver o editar este controlador.'
    end
  end

  def set_controlador
    @controlador = Controlador.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to controladores_path, alert: "Controlador no encontrado."
  end

  def controlador_params
    params.require(:controlador).permit(:nombre, :casilleros_activos, :modelo_id)
  end
end
