class CreateFeaturedContentFeatures < ActiveRecord::Migration[4.2]
  def change
    create_table :featured_content_features do |t|
      t.references :featured_content, index: true, foreign_key: true
      t.datetime :fromdate
      t.datetime :todate

      t.timestamps null: false
    end
  end
end
