class Modelo < ApplicationRecord
  has_many :controladores
  has_many :usuarios
end
