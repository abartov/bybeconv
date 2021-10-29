class CreateFeaturedAuthorFeatures < ActiveRecord::Migration[4.2]
  def change
    create_table :featured_author_features do |t|
      t.datetime :fromdate
      t.datetime :todate
      t.references :featured_author, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
