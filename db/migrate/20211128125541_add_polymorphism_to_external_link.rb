class AddPolymorphismToExternalLink < ActiveRecord::Migration[5.2]
  def change
    add_column :external_links, :linkable_id, :integer
    add_column :external_links, :linkable_type, :string
    add_index :external_links, [:linkable_type, :linkable_id]
    # migrate existing records, all of which must be Manifestations so far
    execute 'update external_links set linkable_type = \'Manifestation\', linkable_id = manifestation_id'
    remove_foreign_key :external_links, column: :manifestation_id
    remove_index :external_links, :manifestation_id
    remove_column :external_links, :manifestation_id

    # making linkable columns not nullable
    change_column :external_links, :linkable_id, :integer, null: false
    change_column :external_links, :linkable_type, :string, null: false
  end
end
