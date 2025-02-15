# frozen_string_literal: true

class IncreasePublisherLineSizeInCollection < ActiveRecord::Migration[6.1]
  def change
    change_column :collections, :publisher_line, :string, limit: 2048   
  end
end
