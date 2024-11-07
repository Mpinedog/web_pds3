class AddPasswordDigestToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :password_digest, :string
  end
end
