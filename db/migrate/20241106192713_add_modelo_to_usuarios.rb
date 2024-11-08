class AddModeloToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_reference :usuarios, :modelo, true, foreign_key: true
  end
end
