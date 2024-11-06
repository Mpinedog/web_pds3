class Casillero < ApplicationRecord
  belongs_to :usuario
  belongs_to :controlador
  belongs_to :metricas
end
