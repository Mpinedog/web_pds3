class AddModeloToControladors < ActiveRecord::Migration[7.1]
  def change
    add_reference :controladors, :modelo, null: false, foreign_key: true
  end
end
