# frozen_string_literal: true

class MigrateCreationsToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    execute <<~sql
      insert into involved_authorities (person_id, role, work_id, created_at, updated_at)
      select
        person_id,
        role,
        work_id,
        created_at,
        updated_at
      from
        creations c
      where
        exists (select 1 from works w where w.id = c.work_id)
    sql

    drop_table :creations
  end
end
