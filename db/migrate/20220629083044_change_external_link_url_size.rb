class ChangeExternalLinkUrlSize < ActiveRecord::Migration[5.2]
  def change
    change_column :external_links, :url, :string, limit: 2048    
  end
end
