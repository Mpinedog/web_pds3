class Manager < ApplicationRecord
  self.table_name = "managers"
  belongs_to :user
  belongs_to :predictor , optional: true
  has_many :lockers

  after_update :sync_if_predictor_changed, if: :saved_change_to_predictor_id?

  private

  def sync_if_predictor_changed
    SynchronizationService.new(self).call
  end

end
