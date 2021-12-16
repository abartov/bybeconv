module V1
  module Entities
    class V1::Entities::ManifestationEnrichment < Grape::Entity
      expose :external_links, using: V1::Entities::ExternalLink, documentation: { is_array: true } do |manifestation_id|
        ::ExternalLink.where(linkable_type: :Manifestation, linkable_id: manifestation_id).status_approved.order(:id)
      end

      expose :taggings, documentation: { is_array: true } do |manifestation_id|
        Tag.approved.joins(:taggings).merge(Tagging.where(manifestation_id: manifestation_id)).pluck(:name).sort
      end

      expose :recommendations, using: V1::Entities::Recommendation, documentation: { is_array: true } do |manifestation_id|
        ::Recommendation.approved.where(manifestation_id: manifestation_id).preload(:user)
      end

      expose :texts_about, documentation: { type: 'Integer', is_array: true } do |manifestation_id|
        w = ::Work.joins(expressions: :manifestations).where('manifestations.id = ?', manifestation_id)
        Aboutness.where(aboutable: w)
                 .joins(work: {expressions: :manifestations})
                 .pluck('manifestations.id').sort
      end
    end
  end
end
