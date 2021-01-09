class IncreaseCachedPeopleSize < ActiveRecord::Migration[5.2]
  def change
    change_column :manifestations, :cached_people, :text, limit: 24000 # needed for some anthologies and other multi-author collections
  end
end
