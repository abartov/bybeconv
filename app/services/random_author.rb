# frozen_string_literal: true

# Service to fetch random author
class RandomAuthor < ApplicationService
  def call(genre = nil)
    relation = Person.has_toc
                     .where(
                       <<~SQL.squish,
                         exists (
                           select 1 from
                             creations c
                             join works w on (c.work_id = w.id)
                             join expressions e on (e.work_id = w.id)
                             join manifestations m on (m.expression_id = e.id)
                           where
                             c.person_id = people.id
                             and m.status = ?
                             and w.genre = coalesce(?, w.genre)
                         )
                       SQL
                       Manifestation.statuses[:published],
                       genre
                     )
    relation.order(Arel.sql('rand()')).first
  end
end
