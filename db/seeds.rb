# db/seeds.rb
require 'faker'

# Limpiar la base de datos para evitar duplicados
Usuario.destroy_all
Modelo.destroy_all
Controlador.destroy_all
Casillero.destroy_all
Metrica.destroy_all

# Crear Modelos de Gestos
3.times do
  Modelo.create!(
    sign1: Faker::Alphanumeric.alpha(number: 3),
    sign2: Faker::Alphanumeric.alpha(number: 3),
    sign3: Faker::Alphanumeric.alpha(number: 3),
    sign4: Faker::Alphanumeric.alpha(number: 3),
    sign5: Faker::Alphanumeric.alpha(number: 3),
    sign6: Faker::Alphanumeric.alpha(number: 3)
  )
end

# Crear Usuarios usando Devise
3.times do
  Usuario.create!(
    email: Faker::Internet.unique.email,            # Campo `email` que Devise requiere
    username: Faker::Internet.username,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    password: 'password',                           # Contraseña para Devise
    password_confirmation: 'password',              # Confirmación de contraseña
    modelo: Modelo.order("RANDOM()").first          # Asigna un modelo aleatorio a cada usuario
  )
end

# Crear Métricas
3.times do
  Metrica.create!(
    cant_aperturas: Faker::Number.between(from: 1, to: 100),
    cant_intentos_fallidos: Faker::Number.between(from: 1, to: 50),
    cant_cambios_contrasena: Faker::Number.between(from: 1, to: 20)
  )
end

# Crear Controladores
3.times do
  Controlador.create!(
    nombre: Faker::Device.model_name,
    casilleros_activos: [true, false].sample,
    usuario: Usuario.order("RANDOM()").first,
    modelo: Modelo.order("RANDOM()").first
  )
end

# Crear Casilleros
3.times do
  Casillero.create!(
    apertura: [true, false].sample,
    clave: Faker::Alphanumeric.alphanumeric(number: 8),
    usuario: Usuario.order("RANDOM()").first,
    controlador: Controlador.order("RANDOM()").first,
    metrica_id: Metrica.order("RANDOM()").first.id
  )
end

puts "Seeding completado: 3 registros creados para cada entidad."
