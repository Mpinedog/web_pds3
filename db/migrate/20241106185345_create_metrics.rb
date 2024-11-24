class CreateMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :metrics do |t|
      t.integer :openings_count
      t.integer :failed_attempts_count
      t.integer :password_changes_count

      t.timestamps
    end
  end
end
