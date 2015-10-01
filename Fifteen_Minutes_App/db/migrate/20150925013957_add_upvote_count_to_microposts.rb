class AddUpvoteCountToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :upvoteCount, :hstore, default: {}, null: false
  end
end
