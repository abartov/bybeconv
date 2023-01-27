class AddPubLinksToHtmlFile < ActiveRecord::Migration[5.2]
  def change
    add_column :html_files, :pub_link, :string
    add_column :html_files, :pub_link_text, :string
  end
end
