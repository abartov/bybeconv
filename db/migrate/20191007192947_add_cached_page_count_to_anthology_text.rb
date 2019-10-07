class AddCachedPageCountToAnthologyText < ActiveRecord::Migration[5.2]
  def change
    add_column :anthology_texts, :cached_page_count, :integer
  end
end
