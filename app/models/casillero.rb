class Casillero < ApplicationRecord
  belongs_to :usuario
  belongs_to :controlador, optional: true
  belongs_to :metrica, class_name: 'Metrica', foreign_key: 'metrica_id', optional: true
  validates :clave, presence: true, format: { with: /\A\d{4}\z/, message: "debe contener exactamente 4 números" },
            length: { is: 4, message: "debe tener exactamente 4 dígitos" },
            numericality: { only_integer: true, message: "debe ser un número" }
end
