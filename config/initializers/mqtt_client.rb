# mqtt_client.rb
require 'mqtt'

MQTT_CLIENT ||= MQTT::Client.connect(
  host: '054cf48ea1764139b07e5ab1da148df0.s1.eu.hivemq.cloud',
  port: 8883,
  username: 'pds_web',
  password: '#Pds123123',
  ssl: true
)

# Suscribirse al tópico y recibir mensajes en un hilo separado
Thread.new do
  MQTT_CLIENT.subscribe('casilleros/status')

  MQTT_CLIENT.get do |topic, message|
    process_message(topic, message)
  end
end

# Método para procesar mensajes recibidos
def process_message(topic, message)
  puts "Mensaje recibido en el tópico #{topic}: #{message}"

  # Parsear el mensaje JSON
  data = JSON.parse(message) rescue {}

  # Asegurarse de que el mensaje tenga el formato esperado
  if data['casilleros'].is_a?(Array)
    data['casilleros'].each do |casillero_data|
      casillero_id = casillero_data['id']
      apertura = casillero_data['apertura']

      # Buscar el casillero por ID y actualizar su estado de apertura
      casillero = Casillero.find_by(id: casillero_id)
      if casillero
        # Incrementar la métrica de aperturas si el casillero se abrió
        if apertura
          casillero.metrica.increment!(:cant_aperturas)
          Rails.logger.info("Casillero #{casillero_id} apertura incrementada. Total aperturas: #{casillero.metrica.cant_aperturas}")
          CasilleroMailer.notificar_apertura(casillero).deliver_now

          casillero.update(apertura: false)
        end
      else
        Rails.logger.warn("Casillero con ID #{casillero_id} no encontrado")
      end
    end
  else
    Rails.logger.warn("Formato de mensaje inválido: #{message}")
  end
end
