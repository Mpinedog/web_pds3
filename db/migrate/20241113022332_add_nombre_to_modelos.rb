class AddNombreToModelos < ActiveRecord::Migration[7.1]
  def change
    add_column :modelos, :nombre, :string
  end
end
