class AddSeparateDatesToPerson < ActiveRecord::Migration
  def change
    add_column :people, :birthdate, :string
    add_column :people, :deathdate, :string

    Person.all.each { |p|
      unless p.dates.nil? or p.dates.empty?
        if p.dates =~ /(\d+-\d+-\d+)-(\d+-\d+-\d+)/
          p.birthdate = $1
          p.deathdate = $2
          p.save!
        elsif p.dates =~ /(\d\d\d+)-(\d+.*)/
          p.birthdate = $1
          p.deathdate = $2
          p.save!
        else
          puts "Unexpected dates format: #{p.dates} -- skipping"
        end
      end
    }
  end
end
