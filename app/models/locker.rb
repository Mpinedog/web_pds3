class Locker < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :manager, optional: true
  has_many :openings, dependent: :destroy
  belongs_to :metric, class_name: 'Metric', foreign_key: 'metric_id', optional: true

  validates :name, presence: true
  validates :password, presence: true, format: { with: /\A\d{4}\z/, message: "debe contener exactamente 4 números" },
            length: { is: 4, message: "debe tener exactamente 4 dígitos" },
            numericality: { only_integer: true, message: "debe ser un número" }
  
  def translate_password_to_colors
    color_map = {
      '1' => 'rojo',
      '2' => 'verde',
      '3' => 'azul',
      '4' => 'morado',
      '5' => 'amarillo',
      '6' => 'rosado',
      '7' => 'naranja',
      '8' => 'azul',
      '9' => 'negro',
      '0' => 'gris'
    }

    password.chars.map { |char| color_map[char] }.join(', ')
  end
end
