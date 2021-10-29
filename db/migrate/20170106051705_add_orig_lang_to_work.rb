class AddOrigLangToWork < ActiveRecord::Migration[4.2]
  def change
    add_column :works, :orig_lang, :string
  end
end
