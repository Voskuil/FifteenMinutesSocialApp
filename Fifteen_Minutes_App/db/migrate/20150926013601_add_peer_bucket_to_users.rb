class AddPeerBucketToUsers < ActiveRecord::Migration
  def change
    add_column :users, :peerBucket, :hstore, default: {}, null: false
  end
end
