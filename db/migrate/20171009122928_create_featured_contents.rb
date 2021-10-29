class CreateFeaturedContents < ActiveRecord::Migration[4.2]
  def change
    create_table :featured_contents do |t|
      t.string :title
      t.references :manifestation, index: true, foreign_key: true
      t.references :person, index: true, foreign_key: true
      t.text :body

      t.timestamps null: false
    end
  end
end
