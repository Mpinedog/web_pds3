class AddModeloToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_reference :usuarios, :modelo, foreign_key: true, null: true
  end
end