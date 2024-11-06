class AddUsuarioToControladors < ActiveRecord::Migration[7.1]
  def change
    add_reference :controladors, :usuario, null: false, foreign_key: true
  end
end
