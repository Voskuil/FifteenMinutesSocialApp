class AddTsvectorColumnToUsers < ActiveRecord::Migration
  # Optimizes full text search by introducing tsvector to cache lexemes
  
  def up
    add_column :users, :search_vector, :tsvector

    execute <<-EOS
      CREATE INDEX users_search_vector_idx ON users USING gin(search_vector);
    EOS
  end

  def down
    remove_column :users, :search_vector
  end
end
