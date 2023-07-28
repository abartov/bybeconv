class FixTaggingConstraints < ActiveRecord::Migration[6.1]
  def change
    execute 'ALTER TABLE taggings DROP CONSTRAINT taggings_manifestation_id_fk'
  end
end
