class AddStatusToHolding < ActiveRecord::Migration
  def change
    add_column :holdings, :status, :integer
  end
end
