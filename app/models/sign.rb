class Sign < ApplicationRecord
  belongs_to :modelo
  has_one_attached :image

  validates :sign_name, presence: true
end
