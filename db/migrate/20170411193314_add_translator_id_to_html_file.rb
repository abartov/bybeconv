class AddTranslatorIdToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :translator_id, :integer
  end
end
