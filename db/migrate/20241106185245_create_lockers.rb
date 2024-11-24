class CreateLockers < ActiveRecord::Migration[7.1]
  def change
    create_table :lockers do |t|
      t.boolean :opening
      t.string :password

      t.timestamps
    end
  end
end
