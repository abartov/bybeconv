class AddDescriptionToExternalLink < ActiveRecord::Migration
  def change
    add_column :external_links, :description, :string
  end
end
