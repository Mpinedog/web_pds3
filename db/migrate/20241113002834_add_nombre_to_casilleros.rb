class AddNombreToCasilleros < ActiveRecord::Migration[7.1]
  def change
    add_column :casilleros, :nombre, :string
  end
end
