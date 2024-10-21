# frozen_string_literal: true

class ChangeCollectionsTitleLength < ActiveRecord::Migration[6.1]
  def change
    change_column :collections, :title, :string, limit: 1024
  end
end
