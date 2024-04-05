module V1
  module Entities
    class ManifestationsPage < Grape::Entity
      expose :total_count, documentation: { type: 'Integer' }
      expose :next_page_search_after,
             documentation: {
               is_array: true,
               desc: <<~DESC
                 Use this value as `search after` to get next page. If null is returned then this page is the last one.
               DESC
             }
      expose :data, using: V1::Entities::ManifestationIndex, documentation: { is_array: true }
    end
  end
end
