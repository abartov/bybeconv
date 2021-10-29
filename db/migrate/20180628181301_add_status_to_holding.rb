class AddStatusToHolding < ActiveRecord::Migration[4.2]
  def change
    add_column :holdings, :status, :integer
  end
end
