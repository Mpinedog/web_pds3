class Locker < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :manager, optional: true
  has_many :openings, dependent: :destroy
  belongs_to :metric, class_name: 'Metric', foreign_key: 'metric_id', optional: true

  validates :name, presence: true
  validates :password, presence: true, format: { with: /\A\d{4}\z/, message: "debe contener exactamente 4 números" },
            length: { is: 4, message: "debe tener exactamente 4 dígitos" },
            numericality: { only_integer: true, message: "debe ser un número" }
end
