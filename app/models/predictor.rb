class Predictor < ApplicationRecord
  before_destroy :ensure_no_associations

  has_many :managers
  has_many :users
  has_many :signs, dependent: :destroy
  accepts_nested_attributes_for :signs, allow_destroy: true

  has_one_attached :txt_file  

  validates :txt_file, presence: true
  validate :txt_file_format

  private

  def txt_file_format
    return unless txt_file.attached?

    # Aceptamos archivos de texto plano
    acceptable_types = ["text/plain"]
    unless acceptable_types.include?(txt_file.content_type)
      errors.add(:txt_file, "debe ser un archivo .txt")
    end
  end

  def ensure_no_associations
    if users.exists? || managers.exists?
      errors.add(:base, "Cannot delete predictor with associated users or managers")
      throw :abort
    end
  end
end
