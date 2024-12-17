# frozen_string_literal: true

class AddCreditSectionToAuthority < ActiveRecord::Migration[6.1]
  def change
    add_column :authorities, :legacy_credits, :text
    add_column :authorities, :cached_credits, :text
  end
end
