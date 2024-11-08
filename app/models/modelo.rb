class Modelo < ApplicationRecord
  has_many :controladores
  has_many :usuarios

  has_many_attached :archivos # Manejo de archivos adjuntos
  has_many_attached :figuras  # Manejo de figuras/símbolos asociados
end
