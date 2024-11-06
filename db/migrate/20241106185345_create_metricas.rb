class CreateMetricas < ActiveRecord::Migration[7.1]
  def change
    create_table :metricas do |t|
      t.integer :cant_aperturas
      t.integer :cant_intentos_fallidos
      t.integer :cant_cambios_contrasena

      t.timestamps
    end
  end
end
