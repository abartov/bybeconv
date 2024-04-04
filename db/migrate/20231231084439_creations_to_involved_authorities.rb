class CreationsToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    # Creations have only two roles: 0 - author and 2 - illustrator, which matches roles in InvolvedAuthority
    execute <<~sql
      insert into involved_authorities (authority_id, authority_type, role, item_id, item_type, created_at, updated_at)
      select
        person_id,
        'Person',
        role,
        work_id,
        'Work',
        created_at,
        updated_at
      from
        creations c
      where
        exists (select 1 from works w where w.id = c.work_id)
    sql
  end
end
