require 'sqlite3'

namespace :dict do
  desc "Import dictionary definitions from a sqlite DB for a given manifestation ID"
  task :import, [:db_file, :mani_id] => :environment do |taskname, args|
    unless args.db_file.nil? or args.mani_id.nil?
      db = SQLite3::Database.new args.db_file
      db.results_as_hash = true
      mani_id = args.mani_id.to_i
      i = 1
      updated = 0
      created = 0
      dict_count = db.execute("SELECT COUNT(*) FROM entries")[0]['COUNT(*)']
      puts "Processing #{dict_count} dictionary entries"
      db.execute("SELECT foreign_id, ordinal, defhead, deftext FROM entries") do |row|
        source_id = row['foreign_id'].to_i
        ordinal = row['ordinal'].to_i
        des = DictionaryEntry.where(manifestation_id: mani_id, source_def_id: source_id, sequential_number: ordinal)
        if des.empty?
          @de = DictionaryEntry.new(manifestation_id: mani_id, source_def_id: source_id, sequential_number: ordinal, defhead: row['defhead'], deftext: row['deftext'])
          created += 1
        else # merge into existing entry
          @de = des.first
          @de.update(defhead: row['defhead'], deftext: row['deftext'])
          updated += 1
        end
        @de.save!
        db.execute("SELECT alias FROM aliases WHERE foreign_id = ?", source_id) do |alrow|
          if DictionaryAlias.where(dictionary_entry_id: @de.id, alias: alrow['alias']).empty?
            al = DictionaryAlias.new(dictionary_entry_id: @de.id, alias: alrow['alias'])
            al.save!
          end
        end
        i += 1
        print "#{i}... " if i % 200 == 0
      end
      puts "done!\nCreated #{created} entries and updated #{updated}."
    else
      puts "please specify the path and filename of the SQLite database with the dictionary entries, and the manifestation ID of the dictionary to import to.\ne.g. rake dict:import[/home/xyzzy/dict.db, 1234]"
    end
  end
end
