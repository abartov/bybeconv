class AddUserIdToFeaturedContent < ActiveRecord::Migration
  def change
    add_reference :featured_contents, :user, index: true, foreign_key: true
  end
end
