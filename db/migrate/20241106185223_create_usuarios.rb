class CreateUsuarios < ActiveRecord::Migration[7.1]
  def change
    create_table :usuarios do |t|
      t.string :mail
      t.string :username
      t.string :first_name
      t.string :last_name
      t.boolean :super_user, default: false, null: false
      t.string :full_name
      t.string :uid
      t.string :avatar_url

      t.timestamps
    end
  end
end
