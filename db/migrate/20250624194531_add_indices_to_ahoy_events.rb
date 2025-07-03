# frozen_string_literal: true

class AddIndicesToAhoyEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :ahoy_events, :item_id, :integer, as: 'properties ->> "$.id"'
    add_column :ahoy_events, :item_type, :string, limit: 50, as: 'properties ->> "$.type"'

    add_index :ahoy_events, %i[item_id item_type name]
  end
end
