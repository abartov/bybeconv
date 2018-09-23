class RemoveSourceNameFromHolding < ActiveRecord::Migration
  def change
    remove_column :holdings, :source_name, :string
  end
end
