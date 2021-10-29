class RemoveSourceNameFromHolding < ActiveRecord::Migration[4.2]
  def change
    remove_column :holdings, :source_name, :string
  end
end
