class AddWikipediaUrlToPerson < ActiveRecord::Migration
  def change
    add_column :people, :wikipedia_url, :string
  end
end
