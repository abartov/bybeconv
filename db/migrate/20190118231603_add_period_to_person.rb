class AddPeriodToPerson < ActiveRecord::Migration[5.2]
  def change
    remove_column :people, :period_id
    add_column :people, :period, :integer
  end
end
