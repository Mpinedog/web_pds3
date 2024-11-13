class Controlador < ApplicationRecord
  self.table_name = "controladores"
  belongs_to :usuario
  belongs_to :modelo, optional: true
  has_many :casilleros
end
