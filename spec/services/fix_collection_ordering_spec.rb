# frozen_string_literal: true

require 'rails_helper'

describe FixCollectionOrdering do
  subject(:call) { described_class.call(collection.id) }

  let!(:collection) { create(:collection) }

  context 'when collection has collisions on seqno' do
    let!(:nested_collection) { create(:collection) }

    let!(:first_item) { create(:collection_item, collection: collection, alt_title: Faker::Book.title, seqno: 2) }
    let!(:second_item) { create(:collection_item, collection: collection, alt_title: Faker::Book.title, seqno: 2) }
    let!(:third_item) { create(:collection_item, collection: collection, item: nested_collection, seqno: 3) }
    let!(:fourth_item) { create(:collection_item, collection: collection, alt_title: Faker::Book.title, seqno: 3) }

    it 'fixes ordering and returns number of fixed collisions' do
      expect(call).to eq(2)

      expect(first_item.reload.seqno).to eq(1)
      expect(second_item.reload.seqno).to eq(2)
      expect(third_item.reload.seqno).to eq(3)
      expect(fourth_item.reload.seqno).to eq(4)
    end
  end

  context 'when collection has no collisions on seqno' do
    let!(:first_item) { create(:collection_item, collection: collection, alt_title: Faker::Book.title, seqno: 3) }
    let!(:second_item) { create(:collection_item, collection: collection, alt_title: Faker::Book.title, seqno: 5) }

    it 'fixes gaps in ordering and returns 0' do
      expect(call).to eq(0)

      expect(first_item.reload.seqno).to eq(1)
      expect(second_item.reload.seqno).to eq(2)
    end
  end
end
