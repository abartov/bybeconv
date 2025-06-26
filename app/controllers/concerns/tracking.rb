# frozen_string_literal: true

# Logic to track record view events
module Tracking
  extend ActiveSupport::Concern

  SPIDERS = [
    'msnbot',
    'yahoo! slurp',
    'googlebot',
    'bingbot',
    'duckduckbot',
    'baiduspider',
    'yandexbot',
    'semrushbot'
  ].freeze

  def spider?
    return @spider unless @spider.nil?

    user_agent = request.user_agent&.downcase
    @spider = user_agent.present? && SPIDERS.any? { |s| user_agent.include?(s) }
  end

  def track_view(record)
    return if spider?

    Ahoy::Event.transaction do
      track_event('view', record)
      record.increment!(:impressions_count) # we simply increase impressions_count here

      # increment! method does not triggers Chewy index update so we do it explicitely here
      # for performance purpose we specify only single field to be updated
      index_class = case record.class.name
                    when 'Collection' then CollectionsIndex
                    when 'Manifestation' then ManifestationsIndex
                    when 'Authority' then AuthoritiesIndex
                    end

      index_class&.send(:import, record, import_fields: [:impressions_count])
    end
  end

  def track_download(record)
    track_event('download', record)
  end

  private

  def track_event(event, record)
    raise "Unknown event: #{event}" unless Ahoy::Event::ALLOWED_NAMES.include?(event)

    return if spider?

    props = {
      type: record.class.name,
      id: record.id
    }
    ahoy.track(event, props)
  end
end
