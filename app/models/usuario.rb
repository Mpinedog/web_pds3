class Usuario < ApplicationRecord
  belongs_to :modelo
  has_many :controladores
  has_many :casilleros
end
