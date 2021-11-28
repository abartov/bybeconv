class AddPolymorphismToExternalLink < ActiveRecord::Migration[5.2]
  def change
    add_column :external_links, :linkable_id, :integer
    add_column :external_links, :linkable_type, :string
    add_index :external_links, [:linkable_type, :linkable_id]
    # migrate existing records, all of which must be Manifestations so far
    ExternalLink.all.each do |l|
      l.linkable_type = 'Manifestation'
      l.linkable_id = l.manifestation_id
      l.save
    end
    remove_foreign_key :external_links, column: :manifestation_id
    remove_index :external_links, :manifestation_id
    remove_column :external_links, :manifestation_id
  end
end
