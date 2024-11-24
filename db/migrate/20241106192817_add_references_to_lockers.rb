class AddReferencesToLockers < ActiveRecord::Migration[7.1]
  def change
    add_reference :lockers, :users, null: false, foreign_key: true
    add_reference :lockers, :manager, foreign_key: { to_table: :lockers }
    add_reference :lockers, :metric, null: false, foreign_key: true
  end
end
