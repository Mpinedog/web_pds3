class MakeManagerOptionalInLockers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :lockers, :manager_id, true
  end
end
