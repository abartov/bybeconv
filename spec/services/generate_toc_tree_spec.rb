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
    let!(:other_authority) { create(:authority) }

    let!(:top_level_collection) { create(:collection) }
    let!(:top_level_collection_with_nested_collections) do
      create(
        :collection,
        authors: [other_authority],
        included_collections: [nested_edited_collection, nested_translated_collection]
      )
    end
    let!(:uncollected_collection) { create(:collection, collection_type: :uncollected) }
    let!(:nested_edited_collection) { create(:collection, editors: [authority]) }
    let!(:nested_translated_collection) { create(:collection, translators: [authority]) }
    let!(:edited_manifestations) do
      create_list(
        :manifestation,
        3,
        collections: [nested_edited_collection],
        editor: authority,
        author: other_authority
      )
    end
    # For translated manifestations we don's specify authority on manifestaton level
    let!(:translated_manifestations) do
      create_list(
        :manifestation,
        2,
        collections: [nested_translated_collection],
        author: other_authority
      )
    end

    let!(:uncollected_manifestations) do
      create_list(:manifestation, 2, author: authority, collections: [uncollected_collection])
    end

    let!(:top_level_manifestations) do
      create_list(:manifestation, 3, author: authority, collections: [top_level_collection])
    end

    let(:top_level_node) { result.find { |n| n.item == top_level_collection } }
    let(:top_level_with_nested_node) { result.find { |n| n.item == top_level_collection_with_nested_collections } }
    let(:uncollected_node) { result.find { |n| n.item == uncollected_collection } }
    let(:nested_edited_node) { top_level_with_nested_node.children.find { |n| n.item == nested_edited_collection } }
    let(:nested_translated_node) do
      top_level_with_nested_node.children.find { |n| n.item == nested_translated_collection }
    end

    it 'runs successfully' do
      expect(result).to contain_exactly top_level_node, top_level_with_nested_node, uncollected_node

      expect(top_level_node.children).to match_array top_level_manifestations
      expect(top_level_with_nested_node.children.map(&:item)).to contain_exactly nested_translated_collection,
                                                                                 nested_edited_collection

      expect(nested_edited_node.children).to match_array edited_manifestations
      expect(nested_translated_node.children).to be_empty
    end
  end
end
