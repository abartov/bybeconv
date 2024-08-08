# frozen_string_literal: true

require 'rails_helper'

describe GenerateTocTree do
  subject(:result) { described_class.call(authority) }

  let!(:authority) { create(:authority, uncollected_works_collection: uncollected_collection) }

  context 'when there are no works or collections' do
    let(:uncollected_collection) { nil }

    it { is_expected.to be_empty }
  end

  context 'when there are works' do
    include_context 'when authority has several collections'

    let(:top_level_node) { find_node(result, top_level_collection) }
    let(:top_level_with_nested_node) { find_node(result, top_level_collection_with_nested_collections) }
    let(:uncollected_node) { find_node(result, uncollected_collection) }
    let(:nested_edited_node) { find_child_node(top_level_with_nested_node, nested_edited_collection) }
    let(:nested_translated_node) { find_child_node(top_level_with_nested_node, nested_translated_collection) }

    it 'runs successfully' do
      expect(result).to contain_exactly top_level_node, top_level_with_nested_node, uncollected_node

      expect(top_level_node.children.map(&:first)).to match_array top_level_manifestations
      expect(
        top_level_with_nested_node.children.map { |c| c.first.item }
      ).to contain_exactly nested_translated_collection,
                           nested_edited_collection

      expect(nested_edited_node.children.map(&:first)).to match_array edited_manifestations
      expect(nested_translated_node.children).to be_empty
    end
  end

  private

  def find_node(nodes, item)
    nodes.find { |n| n.item == item }
  end

  def find_child_node(parent_node, item)
    find_node(parent_node.children.map(&:first), item)
  end
end
