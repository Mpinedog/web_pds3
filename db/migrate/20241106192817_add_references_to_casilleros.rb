class AddReferencesToCasilleros < ActiveRecord::Migration[7.1]
  def change
    add_reference :casilleros, :usuario, null: false, foreign_key: true
    add_reference :casilleros, :controlador, true , foreign_key: { to_table: :controladores }
    add_reference :casilleros, :metrica, null: false, foreign_key: true
  end
end
