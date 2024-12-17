# frozen_string_literal: true

class AddCachedCreditsToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :cached_credits, :text
  end
end
