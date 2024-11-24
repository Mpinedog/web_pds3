class RenameUsersIdToUserIdInLockers < ActiveRecord::Migration[7.1]
  def change
    rename_column :lockers, :users_id, :user_id
  end
end
