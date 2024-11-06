class AddModeloToControladores < ActiveRecord::Migration[7.1]
  def change
    add_reference :controladores, :modelo, null: false, foreign_key: true
  end
end
