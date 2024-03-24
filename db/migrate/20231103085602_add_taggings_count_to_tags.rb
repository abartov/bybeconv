class AddTaggingsCountToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :taggings_count, :integer
  end
end
