class CreateModelos < ActiveRecord::Migration[7.1]
  def change
    create_table :modelos do |t|
      t.string :sign1
      t.string :sign2
      t.string :sign3
      t.string :sign4
      t.string :sign5
      t.string :sign6

      t.timestamps
    end
  end
end
