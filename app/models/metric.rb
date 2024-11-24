class Metric < ApplicationRecord
  has_many :lockers, foreign_key: 'metrics_id'
end
