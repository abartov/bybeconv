class CreateCollectionItems < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_items, id: :integer do |t|
      t.references :collection, foreign_key: true, type: :integer
      t.string :alt_title
      t.text :context
      t.integer :seqno
      t.references :item, polymorphic: true
      t.string :markdown, limit: 2048
      t.timestamps
    end
  end
end
