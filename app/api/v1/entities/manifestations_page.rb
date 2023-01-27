module V1
  module Entities
    class ManifestationsPage < Grape::Entity
      expose :total_count, documentation: { type: 'Integer' }
      expose :data, using: V1::Entities::ManifestationIndex, documentation: { is_array: true }
    end
  end
end
