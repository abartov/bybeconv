class AddExternalLinkToFeaturedContent < ActiveRecord::Migration
  def change
    add_column :featured_contents, :external_link, :string
  end
end
