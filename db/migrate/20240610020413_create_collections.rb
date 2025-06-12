class CreateCollections < ActiveRecord::Migration[6.1]
  def change
    drop_table :collection_items if table_exists?(:collection_items)
    remove_column :authorities, :root_collection_id if column_exists?(:authorities, :root_collection_id)

    drop_table :collections if table_exists?(:collections)

    create_table :collections, id: :integer do |t|
      t.string :title
      t.string :sort_title
      t.string :subtitle
      t.string :issn
      t.integer :collection_type
      t.string :inception
      t.integer :inception_year
      t.references :publication, foreign_key: true, type: :integer
      t.references :toc, foreign_key: true, type: :integer
      t.integer :toc_strategy
      t.timestamps
    end

    add_index :collections, :sort_title
    add_index :collections, :inception_year

    add_foreign_key :ingestibles, :collections, column: :volume_id
  end
end
