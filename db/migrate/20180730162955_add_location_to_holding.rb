class AddLocationToHolding < ActiveRecord::Migration[4.2]
  def change
    add_column :holdings, :location, :string
  end
end
