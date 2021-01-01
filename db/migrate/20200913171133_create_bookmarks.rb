class CreateBookmarks < ActiveRecord::Migration[5.0]
  def change
    create_table :bookmarks do |t|
      t.references :manifestation, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :bookmark_p
      t.string :context, limit: 250

      t.timestamps
    end
  end
end
