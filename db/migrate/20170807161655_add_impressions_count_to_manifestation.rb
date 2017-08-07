class AddImpressionsCountToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :impressions_count, :int
  end
end
