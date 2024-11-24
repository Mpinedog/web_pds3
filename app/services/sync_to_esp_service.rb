class SyncToEspService
  require 'base64'

  def initialize(locker)
    @locker = locker
  end

  def call
    # Lógica para enviar la sincronización MQTT
    topic = "sincronizar"
    mensaje = {
      id: @locker.id,
      modelo_id: @locker.predictor_id,
      casilleros: @manager.lockers.map { |locker| { id: locker.id, clave: locker.clave } }
    }
    
    if @locker.predictor&.txt_file&.attached?
      contenido_archivo = @manager.predictor.txt_file.download
      mensaje[:archivo_txt] = Base64.encode64(contenido_archivo)
    end
    Rails.logger.info("Enviando mensaje MQTT al topic '#{topic}': #{mensaje.to_json}")
    MQTT_CLIENT.publish(topic, mensaje.to_json)
    Rails.logger.info("Mensaje MQTT enviado exitosamente al topic '#{topic}'")
  rescue => e
    Rails.logger.error("Error al sincronizar con ESP: #{e.message}")
  end
end
