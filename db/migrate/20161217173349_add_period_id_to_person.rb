class AddPeriodIdToPerson < ActiveRecord::Migration
  def change
    add_column :people, :period_id, :integer
  end
end
