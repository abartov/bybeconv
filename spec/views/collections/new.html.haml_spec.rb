require 'rails_helper'

RSpec.describe "collections/new", type: :view do
  before(:each) do
    assign(:collection, Collection.new(
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

  it "renders new collection form" do
    render

    assert_select "form[action=?][method=?]", collections_path, "post" do

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
