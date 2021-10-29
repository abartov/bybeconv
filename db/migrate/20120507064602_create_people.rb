class CreatePeople < ActiveRecord::Migration[4.2]
  def change
    create_table :people do |t|
      t.string :name
      t.string :dates
      t.string :title
      t.string :other_designation
      t.string :affiliation
      t.string :country
      t.text :comment

      t.timestamps
    end
    create_table :people_works, :id => false do |t|
      t.timestamps
      t.integer :work_id
      t.integer :person_id
    end

    create_table :expressions_people, :id => false do |t|
      t.timestamps
      t.integer :expression_id
      t.integer :person_id
    end

    create_table :manifestations_people, :id => false do |t|
      t.timestamps
      t.integer :manifestation_id
      t.integer :person_id
    end

  end
end
