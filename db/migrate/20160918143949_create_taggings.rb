class CreateTaggings < ActiveRecord::Migration[4.2]
  def change
    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :manifestation_id
      t.integer :status
      t.integer :suggested_by
      t.integer :approved_by

      t.timestamps
    end
  end
end
