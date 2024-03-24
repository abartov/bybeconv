class CreateCorporateBodies < ActiveRecord::Migration[6.1]
  def change
    create_table :corporate_bodies do |t|
      t.string :name
      t.string :alternate_names
      t.string :location
      t.string :inception
      t.integer :inception_year
      t.string :dissolution
      t.integer :dissolution_year
      t.string :wikidata_uri
      t.string :viaf_id
      t.text :comments

      t.timestamps
    end unless table_exists? :corporate_bodies
    add_index :corporate_bodies, :name unless index_exists? :corporate_bodies, :name
  end
end
