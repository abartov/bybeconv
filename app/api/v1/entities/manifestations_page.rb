module V1
  module Entities
    class ManifestationsPage < Grape::Entity
      expose :total_count
      expose :data do |rec|
        data = rec[:data]
        if data.first.class.name == 'Manifestation'
          V1::Entities::Manifestation.represent rec[:data], view: options[:view], file_format: options[:file_format], snippet: options[:snippet]
        else
          V1::Entities::ManifestationIndex.represent rec[:data], view: options[:view], file_format: options[:file_format], snippet: options[:snippet]
        end
      end
    end
  end
end
