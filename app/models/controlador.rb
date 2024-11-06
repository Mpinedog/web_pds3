class Controlador < ApplicationRecord
  belongs_to :usuario
  belongs_to :modelo

  has_many :casilleros
end
