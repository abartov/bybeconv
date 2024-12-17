# frozen_string_literal: true

class AddCreditsToManifestation < ActiveRecord::Migration[6.1]
  def change
    add_column :manifestations, :credits, :text
  end
end
