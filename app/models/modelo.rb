# app/models/modelo.rb
class Modelo < ApplicationRecord
  has_many :controladores
  has_many :usuarios
  has_many :signs, dependent: :destroy
  accepts_nested_attributes_for :signs, allow_destroy: true

  has_one_attached :tflite_file  # Define un archivo adjunto único llamado tflite_file

  validates :tflite_file, presence: true
  validate :tflite_file_format

  private

  def tflite_file_format
    return unless tflite_file.attached?

    acceptable_types = ["application/octet-stream"]
    unless acceptable_types.include?(tflite_file.content_type)
      errors.add(:tflite_file, "debe ser un archivo .tflite")
    end
  end
end
