class Casillero < ApplicationRecord
  belongs_to :usuario
  belongs_to :controlador
  belongs_to :metricas, class_name: 'Metrica', foreign_key: 'metricas_id', optional: true
end
