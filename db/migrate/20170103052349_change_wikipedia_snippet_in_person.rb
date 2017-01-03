class ChangeWikipediaSnippetInPerson < ActiveRecord::Migration
  def change
    change_column :people, :wikipedia_snippet, :text
  end
end
