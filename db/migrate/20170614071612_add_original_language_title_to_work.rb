class AddOriginalLanguageTitleToWork < ActiveRecord::Migration
  def change
    add_column :works, :origlang_title, :string
  end
end
