class CreateCreations < ActiveRecord::Migration
  def change
    create_table :creations do |t|
      t.integer :work_id
      t.integer :person_id
      t.integer :role
      t.datetime "created_at",              null: false
      t.datetime "updated_at",              null: false
    end
    add_index :creations, :work_id
    add_index :creations, :person_id
    Work.all.each{|w| w.people.each {|p|
      c = Creation.new(work_id: w.id, person_id: p.id, role: :author)
      c.save!
    }}
  end
end
