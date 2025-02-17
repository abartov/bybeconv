# frozen_string_literal: true

class AddAlternateTitlesToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :alternate_titles, :string, limit: 1024
  end
end
