# frozen_string_literal: true

class AddImpressionsCount < ActiveRecord::Migration[6.1]
  def change
    add_column :anthologies, :impressions_count, :integer, default: 0
    add_column :collections, :impressions_count, :integer, default: 0
  end
end
