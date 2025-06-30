# frozen_string_literal: true

# There are simple AhoyEvents like 'search' or 'page_view' and we don't want to store them longer than 6 months
# So this service should be called periodically to clean up old events
class CleanUpSimpleAhoyEvents < ApplicationService
  CLEAN_UP_THRESHOLD = 6.months
  def call
    Ahoy::Event.transaction do
      threshold = CLEAN_UP_THRESHOLD.ago
      # We only clean up events not tied to specific object in db (for objects tied to db we use CompactEvents service)
      Ahoy::Event.where('time < ?', threshold)
                 .where(item_id: nil)
                 .where(item_type: nil)
                 .delete_all
      CleanUpAhoyVisits.call(threshold)
    end
  end
end
