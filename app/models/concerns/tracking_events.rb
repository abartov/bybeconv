# frozen_string_literal: true

# For some models we track views statistics
# We periodically trim those events statistics and create YearTotals records from it to save db space.
module TrackingEvents
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Rails/HasManyOrHasOneDependent
    has_many(:ahoy_events, as: :item, class_name: 'Ahoy::Event')
    # rubocop:enable Rails/HasManyOrHasOneDependent
    has_many(:year_totals, as: :item, dependent: :delete_all)
  end
end
