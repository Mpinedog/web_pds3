# app/models/modelo.rb
class Modelo < ApplicationRecord
  has_many :controladores
  has_many :usuarios
  has_many :signs, dependent: :destroy
  accepts_nested_attributes_for :signs, allow_destroy: true

  has_one_attached :txt_file  # Cambiamos a txt_file para aceptar archivos .txt

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
end
