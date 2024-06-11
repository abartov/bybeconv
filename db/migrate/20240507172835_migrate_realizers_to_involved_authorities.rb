# frozen_string_literal: true

class MigrateRealizersToInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    execute <<~sql
      insert into involved_authorities (person_id, role, expression_id, created_at, updated_at)
      select
        person_id,
        role,
        expression_id,
        created_at,
        updated_at
      from
        realizers r
      where
        exists (select 1 from expressions e where e.id = r.expression_id)
    sql

    drop_table :realizers
  end
end
