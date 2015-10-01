class AddRankToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rank, :hstore, default: {}, null: false
  end
end
