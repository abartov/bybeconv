class AddWikipediaUrlToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :wikipedia_url, :string
  end
end
