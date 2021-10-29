class AddEditorToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :editor, :boolean
  end
end
