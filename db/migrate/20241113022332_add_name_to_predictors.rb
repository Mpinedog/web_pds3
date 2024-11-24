class AddNameToPredictors < ActiveRecord::Migration[7.1]
  def change
    add_column :predictors, :name, :string
  end
end
