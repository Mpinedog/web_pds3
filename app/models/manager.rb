class Manager < ApplicationRecord
  self.table_name = "managers"
  belongs_to :user
  belongs_to :predictor , optional: true
  has_many :lockers

  after_update :sync_if_predictor_changed, if: :saved_change_to_predictor_id?
  validate :mac_address_cannot_be_changed, on: :update

  private

  def sync_if_predictor_changed
    SynchronizationService.new(self).call
  end

  def mac_address_cannot_be_changed
    if mac_address_changed? && mac_address_was.present?
      errors.add(:mac_address, "cannot be changed once assigned")
    end
  end

end
