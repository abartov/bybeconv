class AddTranslatorIdToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :translator_id, :integer
  end
end
