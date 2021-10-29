class AddWikipediaSnippetToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :wikipedia_snippet, :string
  end
end
