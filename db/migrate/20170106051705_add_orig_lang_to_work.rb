class AddOrigLangToWork < ActiveRecord::Migration
  def change
    add_column :works, :orig_lang, :string
  end
end
