# frozen_string_literal: true

# Concern to support raw SQL calls from services
# Be careful when using!
module RawSql
  extend ActiveSupport::Concern

  # runs raw SQL on database
  # @param sql (possibly with params placeholders: ?
  # @param params parameters to use in SQL
  def run_sql(sql, *params)
    st = ActiveRecord::Base.connection.raw_connection.prepare(sql)
    st.execute(*params)
  ensure
    st.close if st.present?
  end

  # Runs 'OPTIMIZE TABLE' SQL command on given table
  # We should run optimization after massive changes in table, like cleaning-up old data, etc.
  # NOTE: this command must be run outside of transaction, as it causes implicit commit
  def optimize_table(table_name)
    run_sql("optimize table #{ActiveRecord::Base.sanitize_sql(table_name)}")
  end
end
