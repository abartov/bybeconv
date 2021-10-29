class AddManifestationIdToExternalLinks < ActiveRecord::Migration[4.2]
  def change
    add_column :external_links, :manifestation_id, :integer
  end
end
