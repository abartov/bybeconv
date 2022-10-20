class RemoveDupeDictionaryEntries < ActiveRecord::Migration[5.2]
  def change
    known_ids = []
    DictionaryEntry.all.each do |entry|
      if known_ids.include?(entry.source_def_id)
        # delete dupe and any links it's involved in
        DictionaryLink.where(from_entry_id: entry.id).destroy_all
        DictionaryLink.where(to_entry_id: entry.id).destroy_all
        entry.destroy
      else
        known_ids << entry.source_def_id 
      end
    end
  end
end
