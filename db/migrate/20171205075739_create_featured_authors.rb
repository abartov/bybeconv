class CreateFeaturedAuthors < ActiveRecord::Migration[4.2]
  def change
    create_table :featured_authors do |t|
      t.string :title
      t.references :user, index: true, foreign_key: true
      t.references :person, index: true, foreign_key: true
      t.text :body

      t.timestamps null: false
    end
  end
end
