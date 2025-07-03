# frozen_string_literal: true

# This service deletes all ahoy_visits created before given date and having no events logged
# Typically this service should be called after ahoy_events cleanup
class CleanUpAhoyVisits < ApplicationService
  def call(date_threshold)
    Ahoy::Visit.where('started_at < ?', date_threshold)
               .where('not exists (select 1 from ahoy_events ae where ae.visit_id = ahoy_visits.id)')
               .delete_all
  end
end
