class AddSeqnoToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :seqno, :integer
  end
end
