# frozen_string_literal: true

class AddCollectionIdToInvolvedAuthority < ActiveRecord::Migration[6.1]
  def change
    add_column :involved_authorities, :collection_id, :integer
    add_index :involved_authorities, :collection_id
  end
end
