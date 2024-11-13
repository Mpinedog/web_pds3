class Sign < ApplicationRecord
  belongs_to :predictor
  has_one_attached :image

  validates :sign_name, presence: true
end
