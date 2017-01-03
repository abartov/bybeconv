class AddWikipediaSnippetToPerson < ActiveRecord::Migration
  def change
    add_column :people, :wikipedia_snippet, :string
  end
end
