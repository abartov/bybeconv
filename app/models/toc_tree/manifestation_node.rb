# frozen_string_literal: true

module TocTree
  # Manifestation node
  class ManifestationNode
    attr_reader :manifestation

    def initialize(manifestation)
      @manifestation = manifestation
    end

    def id
      @id ||= "manifestation:#{@manifestation.id}"
    end

    def visible?(role, authority_id)
      @manifestation.involved_authorities_by_role(role).any? { |a| a.id == authority_id }
    end
  end
end
