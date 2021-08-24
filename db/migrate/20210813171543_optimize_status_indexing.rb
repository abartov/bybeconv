class OptimizeStatusIndexing < ActiveRecord::Migration[5.2]
  def change
    add_index :manifestations, [:status, :sort_title]
  end
end
