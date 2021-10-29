class AddManualFieldsToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :orig_lang, :string
    add_column :html_files, :year_published, :string
    add_column :html_files, :orig_year_published, :string
  end
end
