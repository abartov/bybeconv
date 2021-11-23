module V1
  module Entities
    class ExternalLink < Grape::Entity
      expose :url
      expose :linktype, as: :type
      expose :description
    end
  end
end
