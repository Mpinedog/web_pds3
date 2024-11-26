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
      # Suscribirse a los tópicos "sincronizar", "apertura" y "registros"
      MQTT_CLIENT.subscribe('sincronizar')
      MQTT_CLIENT.subscribe('apertura')
      MQTT_CLIENT.subscribe('registros')

      # Procesar mensajes de todos los tópicos
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

  case topic
  when 'apertura'
    process_opening_message(data)
  when 'registros'
    process_registration_message(data)
  else
    Rails.logger.warn("Tópico desconocido: #{topic}")
  end
end

# Procesar mensaje del tópico "apertura"
def process_opening_message(data)
  unless valid_message_format?(data)
    Rails.logger.warn("Formato de mensaje inválido para apertura: #{data}")
    return
  end

  # Procesar el mensaje basado en el caso
  case data['case']
  when 0
    handle_case_0(data['lockers']) # Caso 0: Apertura exitosa
  when 1
    handle_case_1(data['lockers']) # Caso 1: Fallo en la contraseña
  else
    Rails.logger.warn("Caso desconocido en apertura: #{data['case']}")
  end
end

# Procesar mensaje del tópico "registros"
def process_registration_message(data)
  unless data['mac'] && data['id'] && data['locker_count']
    Rails.logger.warn("Formato de mensaje inválido para registros: #{data}")
    return
  end

  manager = Manager.find_by(id: data['id'])
  if manager
    if manager.mac_address.present?
      if manager.mac_address == data['mac']
        Rails.logger.warn("El manager con ID #{manager.id} ya tiene la misma MAC asignada: #{manager.mac_address}. Proceso detenido.")
      else
        Rails.logger.warn("El manager con ID #{manager.id} ya tiene asignada una MAC diferente: #{manager.mac_address}. No se puede cambiar.")
      end
      return # Detener el proceso completamente si ya hay una MAC asignada
    end

    # Solo se llega aquí si el manager no tiene una MAC asignada
    if manager.update(mac_address: data['mac'])
      create_lockers_for_manager(manager, data['locker_count'].to_i)
      Rails.logger.info("Registro completado para el manager #{manager.id} con MAC #{manager.mac_address}")
    else
      Rails.logger.error("Error al asignar la MAC para el manager #{manager.id}: #{manager.errors.full_messages.join(', ')}")
    end
  else
    Rails.logger.warn("Manager con ID #{data['id']} no encontrado.")
  end
end



# Crear casilleros para un manager
def create_lockers_for_manager(manager, locker_count)
  locker_count.times do |index|
    locker_name = "Locker #{index + 1} (#{manager.name})"
    metric = Metric.create(openings_count: 0, failed_attempts_count: 0, password_changes_count: 0)
    locker = manager.lockers.create(
      name: locker_name,
      password: '1234', # Contraseña predeterminada
      metric: metric,   # Asignar la métrica recién creada
      user_id: nil,     # Inicialmente sin dueño (puede ajustarse si se necesita un usuario)
      opening: false    # Estado inicial cerrado
    )
    if locker.persisted?
      Rails.logger.info("Casillero creado: #{locker.name} (ID: #{locker.id})")
    else
      Rails.logger.error("Error al crear casillero: #{locker.errors.full_messages.join(', ')}")
    end
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
