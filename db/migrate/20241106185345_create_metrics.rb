class CreateMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :metrics do |t|
      t.integer :openings
      t.integer :failed_attemps
      t.integer :password_changes

      t.timestamps
    end
  end
end
