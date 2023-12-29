require 'rails_helper'

RSpec.describe "collection_items/new", type: :view do
  before(:each) do
    assign(:collection_item, CollectionItem.new(
      collection: nil,
      alt_title: "MyString",
      context: "MyText",
      seqno: 1,
      item: nil
    ))
  end

  it "renders new collection_item form" do
    render

    assert_select "form[action=?][method=?]", collection_items_path, "post" do

      assert_select "input[name=?]", "collection_item[collection_id]"

      assert_select "input[name=?]", "collection_item[alt_title]"

      assert_select "textarea[name=?]", "collection_item[context]"

      assert_select "input[name=?]", "collection_item[seqno]"

      assert_select "input[name=?]", "collection_item[item_id]"
    end
  end
end
