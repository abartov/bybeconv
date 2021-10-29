class CreateAnthologies < ActiveRecord::Migration[5.2]
  def change
    create_table :anthologies do |t|
      t.string :title
      t.references :user, foreign_key: true, type: :integer
      t.integer :access
      t.integer :cached_page_count
      t.text :sequence, limit: 16777215

      t.timestamps
    end
  end
end
