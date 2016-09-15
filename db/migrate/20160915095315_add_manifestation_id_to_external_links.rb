class AddManifestationIdToExternalLinks < ActiveRecord::Migration
  def change
    add_column :external_links, :manifestation_id, :integer
  end
end
