require 'mqtt'

# Configuración del cliente MQTT
MQTT_CLIENT ||= MQTT::Client.connect(
  host: 'fe95203494624406b7c8e2cb69f69af7.s1.eu.hivemq.cloud',
  port: 8883,
  username: 'pds_web',
  password: '#Pds123123',
  ssl: true
)

# Manejar la suscripción en un hilo
Thread.new do
  loop do
    begin
      MQTT_CLIENT.subscribe('sincronizar')

      MQTT_CLIENT.get do |topic, message|
        process_message(topic, message)
      end
    rescue MQTT::ProtocolException => e
      Rails.logger.error("Error de protocolo MQTT: #{e.message}")
      sleep(5) # Esperar antes de intentar reconectar
      retry
    rescue => e
      Rails.logger.error("Error inesperado en el cliente MQTT: #{e.message}")
      break
    end
  end
end

# Método para procesar mensajes
def process_message(topic, message)
  Rails.logger.info("Mensaje recibido en el tópico  #{topic}: #{message}")

  # Parsear el mensaje JSON
  data = JSON.parse(message) rescue {}

  # Validar el formato del mensaje
  if data['lockers'].is_a?(Array)
    data['lockers'].each do |locker_data|
      locker_id = locker_data['id']
      opening = locker_data['opening']

      # Buscar el casillero y actualizar
      locker = Locker.find_by(id: locker_id)
      if locker
        if opening
          locker.metric.increment!(:openings_count)
          Rails.logger.info("Casillero #{locker_id} apertura incrementada.")
          LockerMailer.notificar_apertura(locker).deliver_now
          locker.update(opening: false)
        end
      else
        Rails.logger.warn("Casillero con ID #{locker_id} no encontrado")
      end
    end
  else
    Rails.logger.warn("Formato de mensaje inválido: #{message}")
  end
end
