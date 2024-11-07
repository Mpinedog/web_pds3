class Usuario < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable
  
  belongs_to :modelo, optional: true
  has_many :controladores
  has_many :casilleros

  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :email, presence: true, uniqueness: true
  validates :username, :first_name, :last_name, presence: true
end
