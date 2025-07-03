# frozen_string_literal: true

namespace :ahoy do
  desc 'Sum up and compact events records into YearTotals'
  task compact: :environment do
    CompactEvents.call
  end
end
