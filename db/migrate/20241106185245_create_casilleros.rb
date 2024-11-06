class CreateCasilleros < ActiveRecord::Migration[7.1]
  def change
    create_table :casilleros do |t|
      t.boolean :apertura
      t.string :clave

      t.timestamps
    end
  end
end
