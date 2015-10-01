class AddCommonToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :common, :string
  end
end
