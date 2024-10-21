# frozen_string_literal: true

class MakeInvolvedAuthoritiesPolymorphic < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :involved_authorities, :item, polymorphic: true

    execute "update involved_authorities set item_id = work_id, item_type = 'Work' where work_id is not null"
    execute <<~SQL
      update
        involved_authorities
      set
        item_id = expression_id,
        item_type = 'Expression'
      where
        expression_id is not null
    SQL

    execute <<~SQL
      update
        involved_authorities
      set
        item_id = collection_id,
        item_type = 'Collection'
      where
        collection_id is not null
    SQL

    remove_column :involved_authorities, :collection_id
    remove_column :involved_authorities, :work_id
    remove_column :involved_authorities, :expression_id

    change_column :involved_authorities, :item_id, :integer, null: false
    change_column :involved_authorities, :item_type, :string, null: false
  end
end
