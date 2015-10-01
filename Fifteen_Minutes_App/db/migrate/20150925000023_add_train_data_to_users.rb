class AddTrainDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trainData, :hstore, default: {}, null: false
  end
end
