class Metrica < ApplicationRecord
  has_many :casilleros, foreign_key: 'metricas_id'
end
