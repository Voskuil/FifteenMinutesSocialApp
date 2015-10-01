class AddBucketToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bucket, :hstore, default: {}, null: false
  end
end
