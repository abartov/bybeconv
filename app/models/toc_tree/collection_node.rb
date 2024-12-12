# frozen_string_literal: true

module TocTree
  # Collection node
  class CollectionNode
    attr_accessor :collection, :children, :new, :has_parents

    # Item is a collection
    # Children is an array of [x, seqno] where x is a Node (Collection/Manifestation/Placeholder),
    # seqno used for ordering
    def initialize(collection)
      @collection = collection
      @children = []
      @new = true
      @parents = []
      @has_parents = false
    end

    def id
      @id ||= "collection:#{@collection.id}"
    end

    def add_child(child, seqno)
      return if child.nil?

      @children << [child, seqno] unless @children.any? { |ch, _seqno| ch.id == child.id }
      child.has_parents = true if child.is_a?(TocTree::CollectionNode)
    end

    # Checks if given Node should be displayed in TOC tree for given authority and role combination
    def visible?(role, authority_id)
      if @collection.involved_authorities.any? { |ia| ia.role == role.to_s && ia.authority_id == authority_id }
        # authority is specified on collection level with given role
        true
      else
        # or collection contains other items where given authority has given role (recursive check)
        children_by_role(role, authority_id).present?
      end
    end

    # Returns array of child elements (Manifestations or Nodes) where given author is involved with given role
    def children_by_role(role, authority_id)
      @children_by_role ||= {}
      @children_by_role[role] ||= sorted_children.select { |child| child.visible?(role, authority_id) }
    end

    def sorted_children
      @sorted_children ||= children.sort_by { |child, seqno| [seqno, child.id] }.map(&:first)
    end
  end
end
