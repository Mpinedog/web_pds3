class AddReferencesToCasilleros < ActiveRecord::Migration[7.1]
  def change
    add_reference :casilleros, :usuario, null: false, foreign_key: true
    add_reference :casilleros, :controlador, null: false, foreign_key: true
    add_reference :casilleros, :metricas, null: false, foreign_key: true
  end
end
