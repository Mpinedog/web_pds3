class AddUsuarioToControladores < ActiveRecord::Migration[7.1]
  def change
    add_reference :controladores, :usuario, null: false, foreign_key: true
  end
end
