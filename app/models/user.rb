class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
   :recoverable, :rememberable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2]
  
  belongs_to :predictor, optional: true
  has_many :managers
  has_many :lockers

  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :email, presence: true, uniqueness: true
  validates :username, :first_name, :last_name, presence: true

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email if user.email.blank?
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.predictor_id ||= 1

    
    user.save(validate: false)
    user
  end
end
