# frozen_string_literal: true

require 'rails_helper'

describe Collection do
  it 'validates a collection' do
    expect(build(:collection)).to be_valid
    expect { build(:collection, collection_type: 'made_up') }.to raise_error(ArgumentError)
  end

  it 'validates suppress_download_and_print field' do
    collection = build(:collection, suppress_download_and_print: true)
    expect(collection).to be_valid

    collection.suppress_download_and_print = false
    expect(collection).to be_valid

    collection.suppress_download_and_print = nil
    expect(collection).not_to be_valid
  end

  it 'iterates over its collection_items in order' do
    c = create(:collection)
    i1 = create(:collection_item, collection: c, seqno: 1)
    i2 = create(:collection_item, collection: c, seqno: 3)
    i3 = create(:collection_item, collection: c, seqno: 2)
    c.reload
    expect(c.collection_items).to eq [i1, i3, i2]
  end

  it 'can be queried by type' do
    c1 = create(:collection, collection_type: :series)
    c2 = create(:collection, collection_type: :periodical)
    c3 = create(:collection, collection_type: :periodical)
    c4 = create(:collection, collection_type: :other)
    expect(described_class.by_type(:series)).to eq [c1]
    expect(described_class.by_type(:periodical)).to eq [c2, c3]
    expect(described_class.by_type(:other)).to eq [c4]
    expect(described_class.count).to eq 4
  end

  it 'iterates over its collection items and wrapped polymorphic items filtered by polymorphic item type' do
    c = create(:collection)
    m1 = create(:manifestation)
    m2 = create(:manifestation)
    p1 = create(:person)
    i1 = create(:collection_item, collection: c, seqno: 1, item: m1)
    i2 = create(:collection_item, collection: c, seqno: 3, item: m2)
    i3 = create(:collection_item, collection: c, seqno: 2, item: p1)
    expect(c.collection_items_by_type('Manifestation')).to eq [i1, i2]
    expect(c.collection_items_by_type('Person')).to eq [i3]
    expect(c.collection_items_by_type('Collection').count).to eq 0
    expect(c.items_by_type('Manifestation')).to eq [m1, m2]
    expect(c.items_by_type('Person')).to eq [p1]
    expect(c.items_by_type('Collection').count).to eq 0
  end

  it 'can be queried by tag' do
    c1 = create(:collection)
    c2 = create(:collection)
    c3 = create(:collection)
    t1 = create(:tag)
    t2 = create(:tag)
    t3 = create(:tag)
    create(:tagging, tag: t1, taggable: c1)
    create(:tagging, tag: t2, taggable: c1)
    create(:tagging, tag: t2, taggable: c2)
    create(:tagging, tag: t3, taggable: c3)
    expect(described_class.by_tag(t1.id)).to eq [c1]
    expect(described_class.by_tag(t2.id)).to eq [c1, c2]
    expect(described_class.by_tag(t3.id)).to eq [c3]
  end

  it 'has access to an optional associated custom TOC' do
    c = create(:collection)
    t = create(:toc)
    c.toc = t
    c.save!
    expect(c.toc).to eq t
  end

  it 'has access to an optional associated Publication' do
    c = create(:collection)
    p = create(:publication)
    c.publication = p
    c.save!
    expect(c.publication).to eq p
  end

  pending 'lists people associated with it, optionally filtered by role'

  it 'lists tags associated with it' do
    c = create(:collection)
    t1 = create(:tag)
    t2 = create(:tag)
    t3 = create(:tag)
    create(:tagging, tag: t1, taggable: c)
    create(:tagging, tag: t2, taggable: c)
    create(:tagging, tag: t3, taggable: c)
    expect(c.tags).to eq [t1, t2, t3]
  end

  it 'can move an item up in the order' do
    c = create(:collection)
    i1 = create(:collection_item, collection: c, seqno: 1)
    i2 = create(:collection_item, collection: c, seqno: 3)
    i3 = create(:collection_item, collection: c, seqno: 2)
    c.reload
    expect(c.collection_items).to eq [i1, i3, i2]
    c.move_item_up(i2.id)
    expect(c.collection_items.reload).to eq [i1, i2, i3]
  end

  it 'can move an item down in the order' do
    c = create(:collection)
    i1 = create(:collection_item, collection: c, seqno: 1)
    i2 = create(:collection_item, collection: c, seqno: 3)
    i3 = create(:collection_item, collection: c, seqno: 2)
    c.reload
    expect(c.collection_items).to eq [i1, i3, i2]
    c.move_item_down(i1.id)
    expect(c.collection_items.reload).to eq [i3, i1, i2]
  end

  it 'can append an item to the end of the order' do
    c = create(:collection)
    i1 = create(:collection_item, collection: c, seqno: 1)
    i2 = create(:collection_item, collection: c, seqno: 3)
    i3 = create(:collection_item, collection: c, seqno: 2)
    c.reload
    expect(c.collection_items).to eq [i1, i3, i2]
    m = create(:manifestation)
    c.append_item(m)
    expect(c.collection_items.reload.count).to eq 4
    expect(c.collection_items.last.item).to eq m
  end

  it 'can be emptied' do
    c = create(:collection)
    create_list(:collection_item, 5, collection: c)
    expect(c.collection_items.count).to eq 5
    c.reload
    c.collection_items.destroy_all
    expect(c.collection_items.count).to eq 0
  end

  it 'removes an item' do
    c = create(:collection)
    i1 = create(:collection_item, collection: c, seqno: 1)
    i2 = create(:collection_item, collection: c, seqno: 3)
    i3 = create(:collection_item, collection: c, seqno: 2)
    expect(c.collection_items.count).to eq 3
    c.remove_item(i3.id)
    c.reload
    expect(c.collection_items.count).to eq 2
    expect(c.collection_items.first).to eq i1
    expect(c.collection_items.last).to eq i2
  end

  describe '.insert_item_at' do
    subject(:call) { collection.insert_item_at(manifestation, index) }

    let(:collection) { create(:collection) }
    let(:manifestation) { create(:manifestation) }

    let!(:first_item) { create(:collection_item, collection: collection, seqno: 1) }
    let!(:second_item) { create(:collection_item, collection: collection, seqno: 2) }
    let!(:third_item) { create(:collection_item, collection: collection, seqno: 3) }

    let(:inserted_item) { CollectionItem.order(id: :desc).first }

    before do
      collection.reload
      call
      collection.reload
    end

    context 'when insert at the end of the list' do
      let(:index) { 4 }

      it 'inserts successfully' do
        expect(inserted_item).to have_attributes(seqno: 4, item: manifestation)
        expect(collection.collection_items).to eq [first_item, second_item, third_item, inserted_item]
        expect(collection.collection_items.map(&:seqno)).to eq [1, 2, 3, 4]
      end
    end

    context 'when insert at the beginning of the list' do
      let(:index) { 1 }

      it 'inserts successfully' do
        expect(inserted_item).to have_attributes(seqno: 1, item: manifestation)
        expect(collection.collection_items).to eq [inserted_item, first_item, second_item, third_item]
        expect(collection.collection_items.map(&:seqno)).to eq [1, 2, 3, 4]
      end
    end

    context 'when insert at specified position' do
      let(:index) { 2 }

      it 'inserts successfully' do
        expect(inserted_item).to have_attributes(seqno: 2, item: manifestation)
        expect(collection.collection_items).to eq [first_item, inserted_item, second_item, third_item]
        expect(collection.collection_items.map(&:seqno)).to eq [1, 2, 3, 4]
      end
    end

    context 'when association is cached before seqno modification' do
      it 'uses fresh data even with cached association (regression test for issue #635)' do
        # This test reproduces the bug: association cached with old seqno values, 
        # then seqnos are modified, then insert uses stale cache
        
        collection = create(:collection)
        item_a = create(:collection_item, collection: collection, seqno: 1, alt_title: 'A')
        item_b = create(:collection_item, collection: collection, seqno: 2, alt_title: 'B')
        item_c = create(:collection_item, collection: collection, seqno: 3, alt_title: 'C')

        # Pre-load and cache the association with original seqno values [1, 2, 3]
        cached_items = collection.collection_items.to_a
        expect(cached_items.map(&:seqno)).to eq([1, 2, 3])
        expect(cached_items.map(&:alt_title)).to eq(['A', 'B', 'C'])

        # Now modify seqnos directly in the database to create gaps
        # WITHOUT reloading the collection
        item_b.update_column(:seqno, 5)
        item_c.update_column(:seqno, 10)

        # At this point:
        # - Database has: A(1), B(5), C(10)
        # - Cached association still thinks: A(1), B(2), C(3)

        # Now try to insert at position 2 (should go between A and B)
        new_item = create(:manifestation)
        collection.insert_item_at(new_item, 2)

        # Expected: new item should have seqno 5 (B's current seqno)
        # Buggy behavior: new item gets seqno 2 (B's old cached seqno)
        
        collection.reload
        all_items = collection.collection_items.order(:seqno).to_a
        
        # Verify correct order: A, NEW, B, C
        expect(all_items.map(&:alt_title)).to eq(['A', nil, 'B', 'C'])
        
        # Verify seqno values are correct
        # NEW should have seqno 5, B should be incremented to 6, C to 11
        seqnos = all_items.map(&:seqno)
        expect(seqnos[0]).to eq(1)   # A unchanged
        expect(seqnos[1]).to eq(5)   # NEW item at B's old position
        expect(seqnos[2]).to eq(6)   # B incremented
        expect(seqnos[3]).to eq(11)  # C incremented
      end
    end

    context 'when performing sequential operations with stale cache' do
      it 'maintains correct order across multiple inserts with cached association' do
        collection = create(:collection)
        create(:collection_item, collection: collection, seqno: 1, alt_title: 'Item1')
        create(:collection_item, collection: collection, seqno: 2, alt_title: 'Item2')
        create(:collection_item, collection: collection, seqno: 3, alt_title: 'Item3')

        # Load and cache the association
        expect(collection.collection_items.size).to eq(3)
        expect(collection.collection_items.to_a.map(&:alt_title)).to eq(['Item1', 'Item2', 'Item3'])

        # First insert without reloading
        first_new = create(:manifestation)
        collection.insert_item_at(first_new, 2)

        # The association is now stale - it doesn't know about first_new
        # Try another insert without reloading
        second_new = create(:manifestation)
        collection.insert_item_at(second_new, 3)

        # Verify final order is correct
        collection.reload
        titles = collection.collection_items.pluck(:alt_title)
        
        # Should have 5 items in correct order
        expect(titles.count).to eq(5)
        expect(titles[0]).to eq('Item1')
        expect(titles[1]).to be_nil  # first_new
        expect(titles[2]).to be_nil  # second_new
        expect(titles[3]).to eq('Item2')
        expect(titles[4]).to eq('Item3')
        
        # Verify seqnos are in order
        seqnos = collection.collection_items.pluck(:seqno)
        expect(seqnos).to eq(seqnos.sort)
      end
    end
  end

  it 'knows its parent collections' do
    c = create(:collection)
    p1 = create(:collection)
    p2 = create(:collection)
    create(:collection_item, collection: c, seqno: 1)
    create(:collection_item, collection: p1, seqno: 1, item: c)
    create(:collection_item, collection: p2, seqno: 1, item: c)
    expect(c.parent_collections).to eq [p1, p2]
  end
end
