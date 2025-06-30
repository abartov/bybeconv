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

  # View event is used to track show or print events on object
  # @param record object being viewed (Manifestation, Authority, etc)
  def track_view(record)
    return if spider?

    Ahoy::Event.transaction do
      track_event('view', record)
      record.increment!(:impressions_count) # we simply increase impressions_count here

      # increment! method does not trigger Chewy index update so we do it explicitly here
      # for performance purpose we specify only single field to be updated
      index_class = case record.class.name
                    when 'Collection' then CollectionsIndex
                    when 'Manifestation' then ManifestationsIndex
                    when 'Authority' then AuthoritiesIndex
                    end

      index_class&.send(:import, record, import_fields: [:impressions_count])
    end
  end

  # Download event should be triggered when we download file associated with object
  # @param object being downloaded (Manifestation, Collection, etc)
  def track_download(record)
    track_event('download', record)
  end

  # Page view event is used to track generic page views
  # `properties` hash will contain controller and action values to identify which page was viewed
  def track_page_view
    track_event('page_view')
  end

  # Generic method used to track random events
  # @param event Event name to be tracked (Ensure it is included in Ahoy::Events::ALLOWED_NAMES)
  # @param record can be either ActiveRecord instance or Hash, specifies additional params to be stored in
  #   event properties. If record is an ActiveRecord it will add `id` and `type` attributes to properties, if record
  #   is a Hash it will simply use them.
  # NOTE: this method always adds to `properties` action and controller names, so no need to add them exlicitely
  def track_event(event, record = nil)
    raise "Unknown event: #{event}" unless Ahoy::Event::ALLOWED_NAMES.include?(event)

    return if spider?

    props = if record.nil?
              {}
            elsif record.is_a?(ActiveRecord::Base)
              {
                type: record.class.name,
                id: record.id
              }
            elsif record.is_a?(Hash)
              record
            else
              raise 'record must be a Hash or ActiveRecord object'
            end

    props[:controller] = controller_name
    props[:action] = action_name

    ahoy.track(event, props)
  end
end
