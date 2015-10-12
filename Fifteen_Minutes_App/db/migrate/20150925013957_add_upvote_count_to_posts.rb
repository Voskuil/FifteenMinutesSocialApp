class AddUpvoteCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :upvoteCount, :hstore, default: {}, null: false
  end
end
