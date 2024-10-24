# frozen_string_literal: true

class AddLegacyTocIdToAuthority < ActiveRecord::Migration[6.1]
  def change
    add_column :authorities, :legacy_toc_id, :integer
  end
end
