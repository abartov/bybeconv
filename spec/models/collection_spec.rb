require 'rails_helper'

RSpec.describe Collection, type: :model do

  it "validates a collection" do
    expect(build(:collection)).to be_valid
    expect { build(:collection, status: :made_up) }.to raise_error(ArgumentError)
  end

  it "iterates over its collection_items in order" do
    c = create(:collection)
    i1 = create(:collection_item, collection: c, seqno: 1)
    i2 = create(:collection_item, collection: c, seqno: 3)
    i3 = create(:collection_item, collection: c, seqno: 2)
    expect(c.collection_items).to eq [i1, i3, i2]
  end

  it "can be queried by type" do
    c1 = create(:collection, collection_type: :anthology)
    c2 = create(:collection, collection_type: :periodical)
    c3 = create(:collection, collection_type: :periodical)
    c4 = create(:collection, collection_type: :other)
    expect(Collection.by_type(:anthology)).to eq [c1]
    expect(Collection.by_type(:periodical)).to eq [c2, c3]
    expect(Collection.by_type(:other)).to eq [c4]
    expect(Collection.count).to eq 4
  end

  it "iterates over its collection items and wrapped polymorphic items filtered by polymorphic item type" do
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

  it "can be queried by tag" do
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
    expect(Collection.by_tag(t1.id)).to eq [c1]
    expect(Collection.by_tag(t2.id)).to eq [c1, c2]
    expect(Collection.by_tag(t3.id)).to eq [c3]
  end

  it "has access to an optional associated custom TOC" do
  end
  it "has access to an optional associated Publication" do
  end
  it "lists people associated with it, optionally filtered by role" do
  end
  it "lists tags associated with it" do
    c = create(:collection)
    t1 = create(:tag)
    t2 = create(:tag)
    t3 = create(:tag)
    create(:tagging, tag: t1, taggable: c)
    create(:tagging, tag: t2, taggable: c)
    create(:tagging, tag: t3, taggable: c)
    expect(c.tags).to eq [t1, t2, t3]
  end
  it "can move an item up in the order" do
  end
  it "can move an item down in the order" do
  end
  it "can append an item to the end of the order" do
  end
  it "can be emptied" do
    c = create(:collection)
    5.times { create(:collection_item, collection: c) }
    expect(c.collection_items.count).to eq 5
    c.collection_items.destroy_all
    expect(c.collection_items.count).to eq 0
  end
end
