# frozen_string_literal: true

module V1
  module Entities
    # API representation for CorporateBody objects
    class CorporateBody < Grape::Entity
      expose :location
      expose :inception_year, documentation: { type: 'Integer' }
      expose :dissolution_year, documentation: { type: 'Integer' }
    end
  end
end
