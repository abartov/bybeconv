class AddNormalizedDateToWork < ActiveRecord::Migration[5.2]
  def change
    add_column :works, :normalized_pub_date, :string
    add_index :works, :normalized_pub_date
    add_column :works, :normalized_creation_date, :string
    add_index :works, :normalized_creation_date
  end
end
