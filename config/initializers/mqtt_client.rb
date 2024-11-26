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
      # Suscribirse a los tópicos "sincronizar" y "apertura"
      MQTT_CLIENT.subscribe('sincronizar')
      MQTT_CLIENT.subscribe('apertura')

      # Procesar mensajes de ambos tópicos
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
  Rails.logger.info("Mensaje recibido en el tópico #{topic}: #{message}")

  # Parsear el mensaje JSON
  data = JSON.parse(message) rescue {}

  # Validar el formato del mensaje
  if !valid_message_format?(data)
    Rails.logger.warn("Formato de mensaje inválido: #{message}")
    return
  end

  # Procesar el mensaje basado en el caso
  case data['case']
  when 0
    handle_case_0(data['lockers']) # Caso 0: Apertura exitosa
  when 1
    handle_case_1(data['lockers']) # Caso 1: Fallo en la contraseña
  else
    Rails.logger.warn("Caso desconocido: #{data['case']}")
  end
end

# Manejar el caso 0: El locker se abrió
def handle_case_0(lockers)
  lockers.each do |locker_data|
    locker_id = locker_data['id']
    locker = Locker.find_by(id: locker_id)
    
    if locker
      locker.metric.increment!(:openings_count)
      Rails.logger.info("Casillero #{locker_id}: Apertura registrada.")
      LockerMailer.notify_opening(locker).deliver_now
    else
      Rails.logger.warn("Casillero con ID #{locker_id} no encontrado")
    end
  end
end

# Manejar el caso 1: Fallo en la contraseña
def handle_case_1(lockers)
  lockers.each do |locker_data|
    locker_id = locker_data['id']
    locker = Locker.find_by(id: locker_id)
    
    if locker && locker.metric.present?
      locker.metric.increment!(:failed_attempts_count)
      Rails.logger.info("Casillero #{locker_id}: Fallo en la apertura registrado.")
    else
      Rails.logger.warn("Casillero con ID #{locker_id} no encontrado o métrica no asociada")
    end
  end
end

# Método para validar el formato del mensaje
def valid_message_format?(data)
  data.is_a?(Hash) && data['lockers'].is_a?(Array)
end
