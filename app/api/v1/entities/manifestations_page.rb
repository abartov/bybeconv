module V1
  module Entities
    class V1::Entities::ManifestationsPage < Grape::Entity
      expose :total_count
      expose :data do |rec|
        data = rec[:data]
        if data.first.class.name == 'Manifestation'
          V1::Entities::Manifestation.represent rec[:data], view: options[:view], file_format: options[:file_format]
        else
          V1::Entities::ManifestationIndex.represent rec[:data], view: options[:view], file_format: options[:file_format]
        end
      end
    end
  end
end
