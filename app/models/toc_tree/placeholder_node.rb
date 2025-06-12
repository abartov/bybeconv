# frozen_string_literal: true

module TocTree
  # Placeholder node
  class PlaceholderNode
    attr_reader :collection_item

    def initialize(collection_item)
      @collection_item = collection_item
    end

    def id
      @id ||= "placeholder:#{@collection_item.id}"
    end

    def visible?(role, authority_id)
      # Placeholder should be visible if authority is involved in parent collection with given role
      @collection_item.collection.involved_authorities.any? do |ia|
        ia.role == role.to_s && ia.authority_id == authority_id
      end
    end

    def alt_title
      @collection_item.alt_title
    end

    def markdown
      @collection_item.markdown
    end
  end
end
