# frozen_string_literal: true

class ChangeUniqueIndexInYearTotals < ActiveRecord::Migration[6.1]
  def change
    remove_index :year_totals, [:item_type, :item_id, :year]
    add_index :year_totals, [:item_id, :item_type, :year, :event], unique: true
  end
end
