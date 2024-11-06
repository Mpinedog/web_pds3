class Casillero < ApplicationRecord
  belongs_to :dueno
  belongs_to :controlador
  belongs_to :metricas
end
