class AddExternalLinkToFeaturedContent < ActiveRecord::Migration[4.2]
  def change
    add_column :featured_contents, :external_link, :string
  end
end
