class AddImpressionsCountToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :impressions_count, :int
  end
end
