class AddPredictorToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :predictor, foreign_key: true, null: true
  end
end