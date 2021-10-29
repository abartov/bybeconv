class AddImpressionsCountToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :impressions_count, :int
  end
end
