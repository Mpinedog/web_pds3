class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  
  belongs_to :predictor, optional: true
  has_many :managers, dependent: :destroy
  has_many :lockers

  after_save :assign_predictor_to_managers, if: -> { saved_change_to_predictor_id? && predictor.present? }

  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :email, presence: true, uniqueness: true
  validates :username, :first_name, :last_name, presence: true

  def super_user?
    super_user
  end

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email if user.email.blank?
    user.password = Devise.friendly_token[0, 20] if user.new_record?

    user.save(validate: false)
    user
  end

  def assign_predictor_to_managers
    managers.update_all(predictor_id: predictor_id)
    managers.each do |manager|
      SyncToEspService.new(manager).call
    end
  end
end
