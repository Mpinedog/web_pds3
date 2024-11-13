require 'mqtt'

MQTT_CLIENT = MQTT::Client.connect(
  host: '054cf48ea1764139b07e5ab1da148df0.s1.eu.hivemq.cloud', # Reemplaza con el host de tu broker MQTT
  port: 8883,                # Puerto MQTT estándar
  username: 'pds_web',          # Usuario si es necesario
  password: '#Pds123123',       # Contraseña si es necesario
  ssl: true                     # Usar conexión segura (TLS)
)
