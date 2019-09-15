require 'csv'
desc "Dump a CSV with people, Wikidata QIDs, VIAF IDs, and dates"
task :dump_people => :environment do
  row = ['benyehuda.org ID', 'name','Wikidata QID','VIAF','Birth date', 'Death date']
  CSV.open('benyehuda_people.csv', 'w') do |c|
    c << row
    Person.all.each{ |p| c << [p.id, p.name, p.wikidata_id, p.viaf_id, p.birthdate, p.deathdate]}
  end
end