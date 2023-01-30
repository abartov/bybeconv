class IncreaseCachedTocSize < ActiveRecord::Migration[5.2]
  def change
    change_column :tocs, :cached_toc, :text, :limit => 16777210 # near mediumtext limit, more than enough for any toc

  end
end
