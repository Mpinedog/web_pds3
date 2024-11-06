class CreateControladors < ActiveRecord::Migration[7.1]
  def change
    create_table :controladors do |t|
      t.string :nombre
      t.boolean :casilleros_activos

      t.timestamps
    end
  end
end
