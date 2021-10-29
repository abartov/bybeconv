class AddScanUrlToHolding < ActiveRecord::Migration[4.2]
  def change
    add_column :holdings, :scan_url, :string, limit: 2048
  end
end
