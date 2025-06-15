# frozen_string_literal: true

# We periodically run db:cleanup:trim rake task to clean stale session records but it lefts us with hanging
# BaseUser records.
# So we need to delete BaseUsers linked to deleted sessions too. This enhance will run base_user cleanup right after
# each db:sessions:trim call
Rake::Task['db:sessions:trim'].enhance do
  CleanUpBaseUsers.call
end
