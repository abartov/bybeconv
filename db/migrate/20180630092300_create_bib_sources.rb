class CreateBibSources < ActiveRecord::Migration[4.2]
  def change
    create_table :bib_sources do |t|
      t.string :title
      t.integer :source_type
      t.string :url
      t.integer :port
      t.string :api_key
      t.text :comments

      t.timestamps null: false
    end
  end
end
