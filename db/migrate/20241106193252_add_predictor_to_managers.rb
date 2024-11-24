class AddPredictorToManagers < ActiveRecord::Migration[7.1]
  def change
    add_reference :managers, :predictor,  foreign_key: true, null: true
  end
end
