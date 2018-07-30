class AddLocationToHolding < ActiveRecord::Migration
  def change
    add_column :holdings, :location, :string
  end
end
