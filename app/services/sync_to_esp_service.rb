# app/services/sync_to_esp_service.rb
class SyncToEspService
  require 'base64'

  def initialize(controlador)
    @controlador = controlador
  end

  def call
    # Lógica para enviar la sincronización MQTT
    topic = "sincronizar"
    mensaje = {
      id: @controlador.id,
      modelo_id: @controlador.modelo_id,
      casilleros: @controlador.casilleros.map { |casillero| { id: casillero.id, clave: casillero.clave } }
    }
    
    if @controlador.modelo&.txt_file&.attached?
      contenido_archivo = @controlador.modelo.txt_file.download
      mensaje[:archivo_txt] = Base64.encode64(contenido_archivo)
    end
    Rails.logger.info("Enviando mensaje MQTT al topic '#{topic}': #{mensaje.to_json}")
    MQTT_CLIENT.publish(topic, mensaje.to_json)
    Rails.logger.info("Mensaje MQTT enviado exitosamente al topic '#{topic}'")
  rescue => e
    Rails.logger.error("Error al sincronizar con ESP: #{e.message}")
  end
end
