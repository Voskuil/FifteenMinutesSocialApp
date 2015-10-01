class AddRankToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :rank, :float, default: 0, null: false
  end
end
