class AddMacAddressToManagers < ActiveRecord::Migration[7.1]
  def change
    add_column :managers, :mac_address, :string
  end
end
