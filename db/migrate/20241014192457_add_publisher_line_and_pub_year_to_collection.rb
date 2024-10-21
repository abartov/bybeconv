# frozen_string_literal: true

class AddPublisherLineAndPubYearToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :publisher_line, :string
    add_column :collections, :pub_year, :string
    add_column :collections, :normalized_pub_year, :integer
  end
end
