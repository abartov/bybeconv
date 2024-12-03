# frozen_string_literal: true

# Service to generate collections-based TOC tree for a single authority
class GenerateTocTree < ApplicationService
  # Node represents a single collection
  class Node
    attr_accessor :item, :children, :new, :has_parents

    # Item is a collection
    # Children is an array of [x, seqno] where x is a manifestations, string (placeholder) or other
    # node (representing sub-collection)
    def initialize(item)
      @item = item
      @children = []
      @new = true
      @has_parents = false
    end

    def add_child(child, seqno)
      @children << [child, seqno] unless child.nil? || @children.any? { |ch, _seqno| ch == child }
      child.has_parents = true if child.is_a?(Node)
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
        elsif child.is_a?(Collection)
          # child is a node representing other collection
          child.visible?(role, authority_id)
        else
          # All placeholders should be shown
          true
        end
      end
    end

    def sorted_children
      @sorted_children ||= children.sort_by do |child, seqno|
        date = if child.is_a?(Node)
                 child.item.created_at
               elsif child.is_a?(Manifestation)
                 child.created_at
               else
                 # Placeholders
                 Time.zone.today
               end
        [
          seqno,
          date
        ]
      end.map(&:first)
    end
  end

  def call(authority)
    @authority = authority
    @nodes = {}

    build_collection_tree
    fetch_manifestations

    current_level = top_level_nodes

    current_level = get_parents(current_level) until current_level.empty?

    top_level_nodes
  end

  private

  def top_level_nodes
    @nodes.values.reject(&:has_parents)
  end

  # This is a first step of building TOC tree
  # We check all collections where authority is involved on collection level and fetch all their children
  # down to the bottom
  def build_collection_tree
    # Fetching all collections authority is directly involved into on collection level
    nodes = @authority.collections.map do |collection|
      node(collection, nil, nil)
    end

    nodes = fetch_children(nodes) until nodes.empty?
  end

  # This is a second step of building TOC tree
  # We check all manifestations whene authority is directly involved, and fetching all their parent collections
  # NOTE: we assume every manifestation must be included at least in one collection (either 'normal' or 'uncollected')
  def fetch_manifestations
    manifestations = @authority.manifestations(:author, :translator, :editor)
                               .preload(collection_items: :collection).with_involved_authorities

    manifestations.each do |manifestation|
      manifestation.collection_items.each do |collection_item|
        col = collection_item.collection
        # We should not include in results 'uncollected' collections belonging to other authorities
        next if col.uncollected? && col.id != @authority.uncollected_works_collection_id

        node(col, manifestation, collection_item.seqno)
      end
    end
  end

  # Fetches children of given collection node and adds them as children to it
  # Returns list of child nodes representing other sub-collections (only not yet traversed)
  def fetch_children(parent_nodes)
    next_level = []
    parent_nodes.each do |parent_node|
      parent_node.item.collection_items.preload(:item).map do |ci|
        child_item = if ci.paratext?
                       # placeholder with markdown
                       MultiMarkdown.new(ci.markdown).to_html
                     elsif ci.item.nil?
                       # placeholder with title only
                       ci.alt_title
                     elsif ci.item.is_a?(Collection)
                       # nested collection
                       item = node(ci.item, nil, nil)
                       item.has_parents = true
                       if item.new
                         next_level << item
                       end
                       item
                     else
                       # manifestation
                       ci.item
                     end
        parent_node.add_child(child_item, ci.seqno)
      end
    end
    next_level
  end

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
      next if parent_collection_items.empty?

      parent_collection_items.each do |collection_item|
        parent_node = node(collection_item.collection, node, collection_item.seqno)
        parents << parent_node if parent_node.new
      end
    end
    parents
  end
end
