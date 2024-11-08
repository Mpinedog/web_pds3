class AddModeloToControladores < ActiveRecord::Migration[7.1]
  def change
    add_reference :controladores, :modelo,  foreign_key: true, null: true
  end
end
