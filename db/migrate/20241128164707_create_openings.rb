class CreateOpenings < ActiveRecord::Migration[7.1]
  def change
    create_table :openings do |t|
      t.references :locker, null: false, foreign_key: true
      t.datetime :opened_at, null: false

      t.timestamps
    end
  end
end
