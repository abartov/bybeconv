# frozen_string_literal: true

# Base class for all models in BY project
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def update_sort_title!
    self.title = title.strip.gsub(/\p{Space}*$/, '') if title.present? # strip is insufficient as it doesn't remove nbsps, which are sometimes coming from bibliographic data
    return unless sort_title.blank? || (title_changed? && !sort_title_changed?)

    self.sort_title = title.strip_nikkud.tr('[]()*"\'', '').tr('-־', ' ').strip
    self.sort_title = ::Regexp.last_match.post_match if sort_title =~ /^\d+\. /
  end
end
