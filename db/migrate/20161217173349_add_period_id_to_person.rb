class AddPeriodIdToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :period_id, :integer
  end
end
