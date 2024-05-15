# frozen_string_literal: true

# Service to fetch random author
class RandomAuthor < ApplicationService
  def call(genre = nil)
    relation = Person.has_toc
                     .where(
                       <<~SQL.squish,
                         exists (
                           select 1 from
                             involved_authorities ia
                             join works w on (ia.work_id = w.id)
                             join expressions e on (e.work_id = w.id)
                             join manifestations m on (m.expression_id = e.id)
                           where
                             ia.person_id = people.id
                             and ia.role = ?
                             and m.status = ?
                             and w.genre = coalesce(?, w.genre)
                         )
                       SQL
                       InvolvedAuthority.roles[:author],
                       Manifestation.statuses[:published],
                       genre
                     )
    relation.order(Arel.sql('rand()')).first
  end
end
