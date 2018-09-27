class ExternalLink < ApplicationRecord
  belongs_to :manifestation

  scope :videos, -> { where(linktype: Manifestation.link_types[:youtube])}
  scope :all_approved, -> { where(status: Manifestation.linkstatuses[:approved])}

end
