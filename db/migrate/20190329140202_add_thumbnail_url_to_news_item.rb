class AddThumbnailUrlToNewsItem < ActiveRecord::Migration[5.2]
  def change
    add_column :news_items, :thumbnail_url, :string
  end
end
