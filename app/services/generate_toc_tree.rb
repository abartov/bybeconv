# frozen_string_literal: true

# Service to generate collections-based TOC tree for a single authority
class GenerateTocTree < ApplicationService
  # Node represents a single collection
  class Node
    attr_accessor :item, :children, :new

    # Item is a collection
    # Children is an array of [x, seqno] where x is a manifestations or other node (representing sub-collection)
    def initialize(item)
      @item = item
      @children = []
      @new = true
    end

    def add_child(child, seqno)
      @children << [child, seqno] unless child.nil? || @children.any? { |ch, _seqno| ch == child }
    end

    # Checks if given Node should be displayed in TOC tree for given authority and role combination
    def visible?(role, authority_id)
      if item.involved_authorities.any? { |ia| ia.role == role.to_s && ia.authority_id == authority_id }
        # authority is specified on collection level with given role
        true
      else
        # or collection contains other items where given authority has given role (will be recursive check)
        children_by_role(role, authority_id).present?
      end
    end

    # Returns array of child elements (Manifestations or Nodes) where given author is involved with given role
    def children_by_role(role, authority_id)
      @children_by_role ||= {}
      @children_by_role[role] ||= sorted_children.select do |child|
        if child.is_a?(Manifestation)
          # child is a Manifestation
          child.involved_authorities_by_role(role).any? { |a| a.id == authority_id }
        else
          # child is a node representing other collection
          child.visible?(role, authority_id)
        end
      end
    end

    def sorted_children
      @sorted_children ||= children.sort_by do |child, seqno|
        [
          seqno,
          child.is_a?(Node) ? child.item.created_at : child.created_at
        ]
      end.map { |child, _seqno| child }
    end
  end

  def call(authority)
    @authority = authority
    manifestations = authority.manifestations(:author, :translator, :editor)
                              .preload(collection_items: :collection).with_involved_authorities
    @nodes = {}
    @top_level = []

    manifestations.each do |manifestation|
      manifestation.collection_items.each do |collection_item|
        col = collection_item.collection
        # We should not include in results 'uncollected' collections belonging to other authorities
        next if col.uncollected? && col.id != @authority.uncollected_works_collection_id

        node(col, manifestation, collection_item.seqno)
      end
    end

    authority.collections.each do |collection|
      node(collection, nil, nil)
    end

    current_level = @nodes.values

    current_level = get_parents(current_level) until current_level.empty?

    @top_level
  end

  private

  # This method either creates a new node with given child, or finds existing node and adds child to it
  def node(collection, child, seqno)
    node = @nodes[collection.id]
    if node.nil?
      node = @nodes[collection.id] = Node.new(collection)
    else
      # This collection was already visited
      node.new = false # marking node as not new
    end

    node.add_child(child, seqno)
    node
  end

  def get_parents(nodes)
    # NOTE: consider using batch loading
    parents = []
    nodes.each do |node|
      parent_collection_items = node.item.parent_collection_items.preload(:collection)
      if parent_collection_items.empty?
        @top_level << node
      else
        parent_collection_items.each do |collection_item|
          parent_node = node(collection_item.collection, node, collection_item.seqno)
          parents << parent_node if parent_node.new
        end
      end
    end
    parents
  end
end
