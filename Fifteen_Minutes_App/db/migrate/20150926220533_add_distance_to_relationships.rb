class AddDistanceToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :distance, :hstore, default: {}, null: false
  end
end
