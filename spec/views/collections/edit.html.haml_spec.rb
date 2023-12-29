require 'rails_helper'

RSpec.describe "collections/edit", type: :view do
  before(:each) do
    @collection = assign(:collection, Collection.create!(
      title: "MyString",
      sort_title: "MyString",
      subtitle: "MyString",
      issn: "MyString",
      collection_type: 1,
      inception: "MyString",
      inception_year: 1,
      publication: nil,
      toc: nil,
      toc_strategy: 1
    ))
  end

  it "renders the edit collection form" do
    render

    assert_select "form[action=?][method=?]", collection_path(@collection), "post" do

      assert_select "input[name=?]", "collection[title]"

      assert_select "input[name=?]", "collection[sort_title]"

      assert_select "input[name=?]", "collection[subtitle]"

      assert_select "input[name=?]", "collection[issn]"

      assert_select "input[name=?]", "collection[collection_type]"

      assert_select "input[name=?]", "collection[inception]"

      assert_select "input[name=?]", "collection[inception_year]"

      assert_select "input[name=?]", "collection[publication_id]"

      assert_select "input[name=?]", "collection[toc_id]"

      assert_select "input[name=?]", "collection[toc_strategy]"
    end
  end
end
