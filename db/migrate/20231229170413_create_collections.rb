class CreateCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :collections do |t|
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
  end
end
