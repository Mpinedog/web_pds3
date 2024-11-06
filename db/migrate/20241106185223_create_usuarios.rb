class CreateUsuarios < ActiveRecord::Migration[7.1]
  def change
    create_table :usuarios do |t|
      t.string :mail
      t.string :username
      t.string :first_name
      t.string :last_name
      t.boolean :super_user

      t.timestamps
    end
  end
end
