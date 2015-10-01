class AddSpecialToUsers < ActiveRecord::Migration
  def change
    add_column :users, :special, :hstore, default: {}, null: false
  end
end
