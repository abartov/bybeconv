# frozen_string_literal: true

# This service is used by periodic job which groups view events by year and creates YearTotals from them
# Afterwards it deletes Ahoy::Events record it used for grouping.
# Records from current year are ignored.
# NOTE: if YEAR_TOTALS record with given params already exists it will add calculated value to existing total value
class CompactEvents < ApplicationService
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
                 .delete_all

      # Visit can be started in previous year, but have some events in current year, so we only delete visits
      # not having events in current year and take in account possible visit duration
      Ahoy::Visit.where('started_at < ?', date_threshold - Ahoy.visit_duration)
                 .where('not exists (select 1 from ahoy_events ae where ae.visit_id = ahoy_visits.id)')
                 .delete_all
    end

    run_sql('optimize table ahoy_events')
    run_sql('optimize table ahoy_visits')
  end

  def run_sql(sql, *params)
    st = ActiveRecord::Base.connection.raw_connection.prepare(sql)
    st.execute(*params)
  ensure
    st.close if st.present?
  end
end
