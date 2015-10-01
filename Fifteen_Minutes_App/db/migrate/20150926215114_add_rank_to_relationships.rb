class AddRankToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :rank, :float, default: 0, null: false
  end
end
