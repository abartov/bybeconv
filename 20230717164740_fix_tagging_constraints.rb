class FixTaggingConstraints < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :taggings, :manifestations
    add_index :taggings, [:taggable_type, :taggable_id]
  end
end
