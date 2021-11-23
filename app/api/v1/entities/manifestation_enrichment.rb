module V1
  module Entities
    class V1::Entities::ManifestationEnrichment < Grape::Entity
      expose :external_links do |manifestation_id|
        links = ::ExternalLink.where(manifestation_id: manifestation_id).status_approved.order(:id)
        V1::Entities::ExternalLink.represent links
      end

      expose :taggings do |manifestation_id|
        Tag.approved.joins(:taggings).merge(Tagging.where(manifestation_id: manifestation_id)).pluck(:name).sort
      end

      expose :recommendations do |manifestation_id|
        recommendations = ::Recommendation.approved.where(manifestation_id: manifestation_id).preload(:user)
        V1::Entities::Recommendation.represent recommendations
      end

      expose :works_about do |manifestation_id|
        w = ::Work.joins(expressions: :manifestations).where('manifestations.id = ?', manifestation_id)
        Aboutness.where(aboutable: w).order(:work_id).pluck(:work_id)
      end
    end
  end
end
