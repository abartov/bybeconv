require 'rails_helper'

RSpec.describe "collection_items/show", type: :view do
  before(:each) do
    @collection_item = assign(:collection_item, CollectionItem.create!(
      collection: nil,
      alt_title: "Alt Title",
      context: "MyText",
      seqno: 2,
      item: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Alt Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
