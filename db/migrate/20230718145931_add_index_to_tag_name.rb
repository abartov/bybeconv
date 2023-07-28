class AddIndexToTagName < ActiveRecord::Migration[6.1]
  def change
    add_index :tag_names, :name, unique: :true
  end
end
