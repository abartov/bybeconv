class AddNeedResequenceToHtmlDir < ActiveRecord::Migration[4.2]
  def change
    add_column :html_dirs, :need_resequence, :boolean
    HtmlDir.update_all('need_resequence = 1')
  end
end
