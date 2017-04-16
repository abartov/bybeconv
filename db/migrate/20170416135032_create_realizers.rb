class CreateRealizers < ActiveRecord::Migration
  def change
    create_table :realizers do |t|
      t.references :expression, index: true, foreign_key: true
      t.references :person, index: true, foreign_key: true
      t.integer :role

      t.timestamps null: false
    end
    Expression.all.each{|e| e.people.each {|p|
      r = Realizer.new(role: p != e.works[0].persons[0] ? :translator : :author)
      r.expression = e
      r.person = p
      r.save!
    }}

  end
end
