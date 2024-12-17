# frozen_string_literal: true

class AddCreditsToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :credits, :text
  end
end
