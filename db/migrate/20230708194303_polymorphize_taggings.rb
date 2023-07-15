class PolymorphizeTaggings < ActiveRecord::Migration[6.1]
  def change
    add_column :taggings, :taggable_type, :string
    rename_column :taggings, :manifestation_id, :taggable_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end
end
