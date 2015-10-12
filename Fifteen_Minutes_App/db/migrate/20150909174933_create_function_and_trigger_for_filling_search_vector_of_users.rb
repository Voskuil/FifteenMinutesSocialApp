class CreateFunctionAndTriggerForFillingSearchVectorOfUsers < ActiveRecord::Migration
  # Optimizes full text search by using a trigger to keep the lexemes up-to-date

  def up
    execute <<-EOS
      CREATE OR REPLACE FUNCTION fill_search_vector_for_user() RETURNS trigger LANGUAGE plpgsql AS $$
      declare
        user_posts record;

      begin
        select string_agg(content, ' ') as content into user_posts from posts where user_id = new.id;
        
        new.search_vector :=
          setweight(to_tsvector('pg_catalog.english', coalesce(new.name, '')), 'A')                  ||
          setweight(to_tsvector('pg_catalog.english', coalesce(new.description, '')), 'B')                ||
		  setweight(to_tsvector('pg_catalog.english', coalesce(new.interest, '')), 'B')                ||
          setweight(to_tsvector('pg_catalog.english', coalesce(user_posts.content, '')), 'B');

        return new;
      end
      $$;
    EOS

    execute <<-EOS
      CREATE TRIGGER users_search_content_trigger BEFORE INSERT OR UPDATE
        ON users FOR EACH ROW EXECUTE PROCEDURE fill_search_vector_for_user();
    EOS

    User.find_each(&:touch)
  end

  def down
    execute <<-EOS
      DROP FUNCTION fill_search_vector_for_user();
      DROP TRIGGER users_search_content_trigger ON users;
    EOS
  end
end
