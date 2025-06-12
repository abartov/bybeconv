# frozen_string_literal: true

class RemoveDatesAndAffiliationFromPeople < ActiveRecord::Migration[6.1]
  def change
    remove_column :people, :dates
    remove_column :people, :affiliation
  end
end
