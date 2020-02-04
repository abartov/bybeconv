class AddNormalizedDateToExpression < ActiveRecord::Migration[5.2]
  def change
    add_column :expressions, :normalized_pub_date, :string
    add_index :expressions, :normalized_pub_date
    add_column :expressions, :normalized_creation_date, :string
    add_index :expressions, :normalized_creation_date
  end
end
