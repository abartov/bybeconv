# frozen_string_literal: true

# This task is used to clean up old simple ahoy_events (not the events we want to compact to YearTotals)
# It should be run periodically and will remove simple events older than 6 months
# We've tied it to db:sessions:trim rake task to cleanup events together with sessions cleanup
Rake::Task['db:sessions:trim'].enhance do
  puts 'Cleaning up simple ahoy events'
  CleanUpSimpleAhoyEvents.call
end
