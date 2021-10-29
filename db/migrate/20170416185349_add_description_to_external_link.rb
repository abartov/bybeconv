class AddDescriptionToExternalLink < ActiveRecord::Migration[4.2]
  def change
    add_column :external_links, :description, :string
  end
end
