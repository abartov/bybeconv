# frozen_string_literal: true

class RemoveRootCollectionIdFromAuthorities < ActiveRecord::Migration[8.0]
  def change
    remove_column :authorities, :root_collection_id, :integer
  end
end
