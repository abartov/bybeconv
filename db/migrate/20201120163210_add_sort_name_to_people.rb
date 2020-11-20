class AddSortNameToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :sort_name, :string
    add_index :people, :sort_name
    add_index :people, :name
    puts "Populating sort_name..."
    Person.all.each do |p|
      p.name.strip!
      ind = p.name.rindex(' ')
      p.sort_name = ind.nil? ? p.name : "#{p.name[ind+1..-1]}, #{p.name[0..ind-1]}"
      p.save!
    end
  end
end
