class RefactorIllustrators < ActiveRecord::Migration[5.2]
  def change
    # Moving all illustrators from realizers table to creations table
    # (we had this role declared in both tables, but decided to leave it only in creations)

    execute <<~SQL
      insert into creations (work_id, person_id, role, created_at, updated_at)
      select ew.work_id, r.person_id, 2, r.created_at, r.updated_at
      from
          realizers r
          join expressions_works ew on r.expression_id = ew.expression_id
      where
          r.role = 2
          and not exists (select 1 from creations c2 where c2.person_id = r.person_id and c2.work_id = ew.work_id and c2.role = 2)
    SQL

    execute 'delete from realizers where role = 2'

  end
end
