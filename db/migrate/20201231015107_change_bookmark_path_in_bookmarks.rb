class ChangeBookmarkPathInBookmarks < ActiveRecord::Migration[5.2]
  def change
    change_column :bookmarks, :bookmark_p, :string
  end
end
