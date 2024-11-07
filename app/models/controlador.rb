class Controlador < ApplicationRecord
  self.table_name = "controladores"
  belongs_to :usuario
  belongs_to :modelo
  has_many :casilleros
end
