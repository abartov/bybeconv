class AddImpressionsCountToPerson < ActiveRecord::Migration
  def change
    add_column :people, :impressions_count, :int
  end
end
