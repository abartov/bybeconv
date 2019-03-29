class CreateNewsItems < ActiveRecord::Migration[5.2]
  def change
    create_table :news_items do |t|
      t.integer :itemtype
      t.string :title
      t.boolean :pinned
      t.datetime :relevance
      t.string :body
      t.string :url
      t.boolean :double

      t.timestamps
    end
    add_index :news_items, :relevance
  end
end
