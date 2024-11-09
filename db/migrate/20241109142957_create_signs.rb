class CreateSigns < ActiveRecord::Migration[7.1]
  def change
    create_table :signs do |t|
      t.string :sign_name
      t.references :modelo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
