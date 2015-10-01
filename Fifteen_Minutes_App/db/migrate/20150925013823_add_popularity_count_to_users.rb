class AddPopularityCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :popularityCount, :hstore, default: {}, null: false
  end
end
