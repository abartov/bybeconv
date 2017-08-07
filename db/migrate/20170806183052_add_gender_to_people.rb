class AddGenderToPeople < ActiveRecord::Migration
  def change
    add_column :people, :gender, :integer
  end
end
