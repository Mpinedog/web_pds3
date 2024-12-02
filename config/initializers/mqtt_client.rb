require 'mqtt'

# Configuración del cliente MQTT
MQTT_CLIENT ||= MQTT::Client.connect(
  host: 'fe95203494624406b7c8e2cb69f69af7.s1.eu.hivemq.cloud',
  port: 8883,
  username: 'pds_web',
  password: '#Pds123123',
  ssl: true
)

# Manejador global de timestamps para la conexión de los managers
LAST_MESSAGE_TIMESTAMPS ||= {}

# Manejar la suscripción en un hilo
Thread.new do
  Rails.logger.info("Iniciando hilo de suscripción MQTT")
  loop do
    begin
      # Suscribirse a los tópicos
      MQTT_CLIENT.subscribe('sincronizar', 'apertura', 'registros', 'conectado')
      Rails.logger.info("Suscrito a los tópicos: sincronizar, apertura, registros, conectado")

      # Procesar mensajes
      MQTT_CLIENT.get do |topic, message|
        process_message(topic, message)
      end
    rescue Errno::ECONNRESET, MQTT::ProtocolException => e
      Rails.logger.error("Error de conexión MQTT: #{e.message}. Reconectando...")
      MQTT_CLIENT.disconnect rescue nil
      MQTT_CLIENT = connect_mqtt_client
      retry
    rescue => e
      Rails.logger.error("Error inesperado en el cliente MQTT: #{e.message}. Reintentando en 5 segundos.")
      sleep(5)
      retry
    end
  end
end

# Verificar periódicamente si los managers están desconectados
Thread.new do
  Rails.logger.info("Iniciando hilo de verificación de estado de managers")
  loop do
    begin
      Manager.where(active: true).find_each do |manager|
        last_message_time = LAST_MESSAGE_TIMESTAMPS[manager.mac_address]
        if last_message_time.nil? || Time.current - last_message_time > 600 # 30 segundos
          manager.update(active: false)
          Rails.logger.info("Manager #{manager.id} marcado como desconectado por inactividad.")

          if manager.user.present?
            UserMailer.notify_disconection(manager.user, manager).deliver_now
            Rails.logger.info("Correo de desconexión enviado a #{manager.user.email}")
          else
            Rails.logger.warn("Manager #{manager.id} sin usuario asociado. No se envió correo de desconexión.")
          end
        end
      end
      sleep(600) # Verificar cada 10 segundos
    rescue => e
      Rails.logger.error("Error en el monitoreo de desconexión: #{e.message}")
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
  when 'conectado'
    process_connected_message(data)
  else
    Rails.logger.warn("Tópico desconocido: #{topic}")
  end
end

# Procesar mensaje del tópico "conectado"
def process_connected_message(data)
  unless data['mac'].present? && data['mode'].present?
    Rails.logger.warn("Formato de mensaje inválido para conectado: #{data}")
    return
  end

  manager = Manager.find_by(mac_address: data['mac'])
  if manager
    case data['mode']
    when 'auto'
      manager.update(active: true)
      LAST_MESSAGE_TIMESTAMPS[data['mac']] = Time.current
      Rails.logger.info("Manager #{manager.id} marcado como conectado por mensaje de estado.")
    when 'manual'
      if data['response'] == "true"
        manager.update(active: true)
        LAST_MESSAGE_TIMESTAMPS[data['mac']] = Time.current
        Rails.logger.info("Manager #{manager.id} marcado como conectado por verifiacion manual.")
      else
        Rails.logger.info("Manager #{manager.id} no se ha conectado por verificacion manual.")
      end
    else
      Rails.logger.warn("Modo desconocido recibido: #{data['mode']}")
    end
  else
    Rails.logger.warn("No se encontró el Manager con MAC: #{data['mac']}")
  end
end





def process_opening_message(data)
  unless data['mac'].present? && data['locker'].present? && data['case'].present?
    Rails.logger.warn("Formato de mensaje inválido para apertura: #{data}")
    return
  end

  manager = Manager.find_by(mac_address: data['mac'])
  if manager
    locker = manager.lockers.offset(data['locker'] - 1).first # Identificar locker por índice
    if locker
      case data['case']
      when 0
        register_successful_opening(locker)
      when 1
        register_failed_attempt(locker)
      when 2
        register_successful_close(locker)
      else
        Rails.logger.warn("Caso desconocido en apertura: #{data['case']}")
      end
    else
      Rails.logger.warn("Locker con índice #{data['locker']} no encontrado para Manager #{manager.id}")
    end
  else
    Rails.logger.warn("Manager con MAC #{data['mac']} no encontrado.")
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
      return
    end

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
      password: '1234',
      metric: metric,
      user_id: nil,
      opening: false
    )
    if locker.persisted?
      Rails.logger.info("Casillero creado: #{locker.name} (ID: #{locker.id})")
    else
      Rails.logger.error("Error al crear casillero: #{locker.errors.full_messages.join(', ')}")
    end
  end
end

# Registrar apertura exitosa
def register_successful_opening(locker)
  locker.openings.create!(opened_at: Time.current)
  locker.metric.increment!(:openings_count)
  Rails.logger.info("Locker #{locker.id} apertura exitosa registrada.")
end

# Registrar intento fallido
def register_failed_attempt(locker)
  locker.metric.increment!(:failed_attempts_count)
  Rails.logger.info("Locker #{locker.id} intento fallido registrado.")
end

# Registrar cierre exitoso
def register_successful_close(locker)
  last_opening = locker.openings.order(opened_at: :desc).find_by(closed_at: nil)
  
  if last_opening
    last_opening.update!(closed_at: Time.current)
    Rails.logger.info("Locker #{locker.id} cierre exitoso registrado.")
  else
    Rails.logger.warn("No se encontró una apertura sin cerrar para el locker #{locker.id}.")
  end
end

# Método para validar el formato del mensaje
def valid_message_format?(data)
  data.is_a?(Hash) && data['lockers'].is_a?(Array)
end
