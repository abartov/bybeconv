class AddUserIdToFeaturedContent < ActiveRecord::Migration[4.2]
  def change
    add_reference :featured_contents, :user, index: true, foreign_key: true
  end
end
