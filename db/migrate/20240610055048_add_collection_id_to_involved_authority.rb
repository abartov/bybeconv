# frozen_string_literal: true

class AddCollectionIdToInvolvedAuthority < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :involved_authorities, :collection, type: :integer, null: true
  end
end
