# frozen_string_literal: true

# This service deletes all base_user records for anonymous users where session record does not exists
# We clean sessions table periodically by running standard rake task 'db:sessions:trim' this service should be
# run after each sessions cleanup
class CleanUpBaseUsers < ApplicationService
  def call
    stale_users = BaseUser.where(user: nil)
                          .where('not exists (select 1 from sessions s where s.session_id = base_users.session_id)')

    Bookmark.where(base_user: stale_users).delete_all

    run_sql("delete from base_user_preferences where base_user_id in (#{stale_users.select(:id).to_sql})")
    stale_users.delete_all

    run_sql('optimize table base_users')
  end

  private

  def run_sql(sql)
    st = ActiveRecord::Base.connection.raw_connection.prepare(sql)
    st.execute
  ensure
    st.close if st.present?
  end
end
