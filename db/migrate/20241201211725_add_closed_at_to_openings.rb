class AddClosedAtToOpenings < ActiveRecord::Migration[7.1]
  def change
    add_column :openings, :closed_at, :datetime
  end
end
