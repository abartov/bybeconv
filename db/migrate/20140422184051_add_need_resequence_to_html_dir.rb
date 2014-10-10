class AddNeedResequenceToHtmlDir < ActiveRecord::Migration
  def change
    add_column :html_dirs, :need_resequence, :boolean
    HtmlDir.update_all('need_resequence = 1')
  end
end
