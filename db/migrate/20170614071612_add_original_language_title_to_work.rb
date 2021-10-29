class AddOriginalLanguageTitleToWork < ActiveRecord::Migration[4.2]
  def change
    add_column :works, :origlang_title, :string
  end
end
