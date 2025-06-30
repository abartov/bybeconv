# frozen_string_literal: true

# This service is used by periodic job which groups view events by year and creates YearTotals from them
# Afterwards it deletes Ahoy::Events record it used for grouping.
# Records from current year are ignored. This service also ignores events not tied to specific object (e.g. page views,
# search requests, etc) as we have separate service to clean them
# NOTE: if YEAR_TOTALS record with given params already exists it will add calculated value to existing total value
class CompactEvents < ApplicationService
  include RawSql

  def call
    date_threshold = Time.now.beginning_of_year

    Ahoy::Event.transaction do
      run_sql(
        <<~SQL.squish,
          insert into year_totals
            (total, year, item_type, item_id, event, created_at, updated_at)
          select total_cnt, year, item_type, item_id, name, current_timestamp(), current_timestamp()
          from (
            select
              count(*) as total_cnt, year(time) as year, item_type, item_id, name
            from
              ahoy_events
            where
              time < ?
              and item_type is not null
              and item_id is not null
            group by
              year(time), item_type, item_id, name
          ) t
          on duplicate key update
            total = total + total_cnt, updated_at = current_timestamp()
        SQL
        date_threshold
      )

      # Deleting events from previous years
      Ahoy::Event.where('time < ?', date_threshold)
                 .where.not(item_type: nil)
                 .where.not(item_id: nil)
                 .delete_all

      CleanUpAhoyVisits.call(date_threshold - Ahoy.visit_duration)
    end
    optimize_table('ahoy_events')
    optimize_table('ahoy_visits')
  end
end
