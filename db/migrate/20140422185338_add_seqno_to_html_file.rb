class AddSeqnoToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :seqno, :integer
  end
end
