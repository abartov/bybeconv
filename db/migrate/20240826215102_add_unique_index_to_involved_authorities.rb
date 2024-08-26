# frozen_string_literal: true

class AddUniqueIndexToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    # cleaning up possible duplicates
    execute <<~SQL
      delete from
        involved_authorities
      using
        involved_authorities, involved_authorities ia2
      where
        ia2.item_type = involved_authorities.item_type
        and ia2.item_id = involved_authorities.item_id
        and ia2.role = involved_authorities.role
        and ia2.authority_id = involved_authorities.authority_id
        and ia2.id < involved_authorities.id
    SQL

    add_index :involved_authorities,
              [:authority_id, :item_id, :item_type, :role],
              unique: true,
              name: :index_involved_authority_uniq
  end
end
