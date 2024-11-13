class Manager < ApplicationRecord
  self.table_name = "managers"
  belongs_to :user
  belongs_to :predictor
  has_many :lockers
end
