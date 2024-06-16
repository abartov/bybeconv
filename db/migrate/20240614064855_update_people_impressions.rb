# frozen_string_literal: true

class UpdatePeopleImpressions < ActiveRecord::Migration[6.1]
  def change
    execute <<~SQL
      update impressions i set 
        impressionable_type = 'Authority',
        impressionable_id = (select a.id from authorities a where a.person_id = i.impressionable_id)
      where
        impressionable_type = 'Person'
    SQL

    execute <<~SQL
      update year_totals yt set
        item_type = 'Authority',
        item_id = (select a.id from authorities a where a.person_id = yt.item_id)
      where
        item_type = 'Person'
    SQL
  end
end
