# frozen_string_literal: true

class MakeProofsPolymorphic < ActiveRecord::Migration[7.0]
  def change
    # We should not have such records, but anyway
    execute "delete from proofs where manifestation_id is null"
    remove_column :proofs, :html_file_id

    add_column :proofs, :item_type, :string
    add_column :proofs, :item_id, :integer

    execute "UPDATE proofs SET item_type = 'Manifestation', item_id = manifestation_id"

    change_column_null :proofs, :item_id, false
    change_column_null :proofs, :item_type, false

    remove_index :proofs, [:status, :manifestation_id]
    remove_column :proofs, :manifestation_id

    add_index :proofs, [:item_id, :item_type, :status]
    add_index :proofs, [:item_type]
  end
end
