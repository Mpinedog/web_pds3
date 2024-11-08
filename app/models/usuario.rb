class Usuario < ApplicationRecord
  devise :database_authenticatable, :registerable,
   :recoverable, :rememberable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2]
  
  belongs_to :modelo, optional: true
  has_many :controladores
  has_many :casilleros

  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :email, presence: true, uniqueness: true
  validates :username, :first_name, :last_name, presence: true

  def self.from_omniauth(auth)
    usuario = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    usuario.email = auth.info.email if usuario.email.blank?
    usuario.password = Devise.friendly_token[0, 20] if usuario.new_record?
    usuario.modelo_id ||= 1

    
    usuario.save(validate: false)
    usuario
  end
end
