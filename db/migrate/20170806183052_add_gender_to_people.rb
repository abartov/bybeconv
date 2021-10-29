class AddGenderToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :gender, :integer
  end
end
