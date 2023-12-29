class CreateCollectionItems < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_items do |t|
      t.references :collection, foreign_key: true
      t.string :alt_title
      t.text :context
      t.integer :seqno
      t.references :item, polymorphic: true

      t.timestamps
    end
  end
end
