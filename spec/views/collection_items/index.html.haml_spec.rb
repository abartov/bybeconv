require 'rails_helper'

RSpec.describe "collection_items/index", type: :view do
  before(:each) do
    assign(:collection_items, [
      CollectionItem.create!(
        collection: nil,
        alt_title: "Alt Title",
        context: "MyText",
        seqno: 2,
        item: nil
      ),
      CollectionItem.create!(
        collection: nil,
        alt_title: "Alt Title",
        context: "MyText",
        seqno: 2,
        item: nil
      )
    ])
  end

  it "renders a list of collection_items" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Alt Title".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
