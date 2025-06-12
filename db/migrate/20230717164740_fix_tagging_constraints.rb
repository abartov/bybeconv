class FixTaggingConstraints < ActiveRecord::Migration[6.1]
  def change
    execute 'ALTER TABLE taggings DROP FOREIGN KEY taggings_manifestation_id_fk'
  end
end
