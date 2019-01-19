class AddPeriodToExpression < ActiveRecord::Migration[5.2]
  def change
    add_column :expressions, :period, :integer
  end
end
