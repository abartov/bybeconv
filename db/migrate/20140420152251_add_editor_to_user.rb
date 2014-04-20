class AddEditorToUser < ActiveRecord::Migration
  def change
    add_column :users, :editor, :boolean
  end
end
