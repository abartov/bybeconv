class ChangeWikipediaSnippetInPerson < ActiveRecord::Migration[4.2]
  def change
    change_column :people, :wikipedia_snippet, :text
  end
end
