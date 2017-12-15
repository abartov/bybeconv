class AddMarkdownToHtmlFile < ActiveRecord::Migration
  TEXT_BYTES = 1_073_741_823

  def change
    add_column :html_files, :markdown, :text, limit: TEXT_BYTES
  end
end
