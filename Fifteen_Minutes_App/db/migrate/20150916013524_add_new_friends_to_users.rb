class AddNewFriendsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :newFriends, :hstore, default: {}, null: false
  end
end
