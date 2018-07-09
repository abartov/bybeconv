class AddScanUrlToHolding < ActiveRecord::Migration
  def change
    add_column :holdings, :scan_url, :string, limit: 2048
  end
end
