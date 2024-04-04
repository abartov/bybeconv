class RealizersToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    # Realizers have only two roles: 1 - editor and 3 - translator, which matches roles in InvolvedAuthority
    execute <<~sql
      insert into involved_authorities (authority_id, authority_type, role, item_id, item_type, created_at, updated_at)
      select
        person_id,
        'Person',
        role,
        expression_id,
        'Expression',
        created_at,
        updated_at
      from
        realizers r
      where
        exists (select 1 from expressions e where e.id = r.expression_id)
    sql

  end
end
