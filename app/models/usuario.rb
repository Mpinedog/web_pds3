class Usuario < ApplicationRecord
  has_secure_password

  belongs_to :modelo, optional: true 
  has_many :controladores
  has_many :casilleros

  validates :mail, presence: true, uniqueness: true
  validates :username, :first_name, :last_name, :password, presence: true
end
