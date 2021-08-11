class AddIndexByGender < ActiveRecord::Migration[5.2]
  def change
    add_index :people, :gender, name: 'gender_index'
    #add_index :people, [:gender, :sequential_number], name: 'gender_index'
  end
end
