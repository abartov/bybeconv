class AddIndexesForPeriod < ActiveRecord::Migration[5.2]
  def change
    add_index :people, :period
    add_index :expressions, :period
  end
end
