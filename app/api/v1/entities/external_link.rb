module V1
  module Entities
    class ExternalLink < Grape::Entity
      expose :url
      expose :linktype, as: :type, documentation: { values: ::ExternalLink.linktypes.keys }
      expose :description
    end
  end
end
