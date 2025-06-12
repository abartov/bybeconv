class AddCacheFieldToToc < ActiveRecord::Migration[5.2]
  def change
    add_column :tocs, :cached_toc, :text
  end
end
