# frozen_string_literal: true

# Service to generate collections-based TOC tree for a single authority
class GenerateTocTree < ApplicationService
  # Node represents a single collection
  class Node
    attr_accessor :item, :children, :new

    # Item is an collection
    # Children is an array of manifestations or other nodes
    def initialize(item, children)
      @item = item
      @children = children
      @new = true
    end

    # Returns array of child elements (Manifestations or Nodes) where given author is invovled with given role
    def children_by_role(role, authority_id)
      @children_by_role ||= {}
      @children_by_role[role] ||= sorted_children.select do |child|
        if child.is_a?(Manifestation)
          # child is a Manifestation
          child.involved_authorities_by_role(role).any? { |a| a.id == authority_id }
        else
          # child is a node representing other collection
          collection = child.item

          if collection.involved_authorities.any? { |ia| ia.role == role && ia.authority_id == authority_id }
            # authority is specified on collection level with given role
            true
          else
            # or collection contains other items where given authority has given role (will be recursive check)
            child.children_by_role(role, authority_id).present?
          end
        end
      end
    end

    def sorted_children
      @sorted_children ||= children.sort_by do |child|
        [
          child.is_a?(Node) ? (child.item.uncollected? ? 1 : 0) : 2,
          child.is_a?(Node) ? child.item.created_at : child.created_at
        ]
      end
    end
  end

  def call(authority)
    manifestations = authority.manifestations(:author, :translator, :editor)
                              .preload(collection_items: :collection).with_involved_authorities
    @nodes = {}
    @top_level = []

    manifestations.each do |manifestation|
      collections = manifestation.collection_items.map(&:collection)
      collections.each do |c|
        node(c, manifestation)
      end
    end

    authority.collections.each do |collection|
      node(collection, nil)
    end

    current_level = @nodes.values

    current_level = get_parents(current_level) until current_level.empty?

    @top_level
  end

  private

  # This method either creates a new node with given child, or finds existing node and adds child to it
  def node(collection, child)
    node = @nodes[collection.id]
    if node.nil?
      node = @nodes[collection.id] = Node.new(collection, [child].compact)
    else
      # This collection was already visited
      node.new = false # marking node as not new
      if child.present? && node.children.exclude?(child)
        node.children << child
      end
    end

    node
  end

  def get_parents(nodes)
    # NOTE: consider using batch loading
    parents = []
    nodes.each do |node|
      parent_collections = node.item.parent_collections
      if parent_collections.empty?
        @top_level << node
      else
        parent_collections.each do |parent_collection|
          parent_node = node(parent_collection, node)
          parents << parent_node if parent_node.new
        end
      end
    end
    parents
  end
end
