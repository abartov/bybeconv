require 'rails_helper'

RSpec.describe "collections/index", type: :view do
  before(:each) do
    assign(:collections, [
      Collection.create!(
        title: "Title",
        sort_title: "Sort Title",
        subtitle: "Subtitle",
        issn: "Issn",
        collection_type: 2,
        inception: "Inception",
        inception_year: 3,
        publication: nil,
        toc: nil,
        toc_strategy: 4
      ),
      Collection.create!(
        title: "Title",
        sort_title: "Sort Title",
        subtitle: "Subtitle",
        issn: "Issn",
        collection_type: 2,
        inception: "Inception",
        inception_year: 3,
        publication: nil,
        toc: nil,
        toc_strategy: 4
      )
    ])
  end

  it "renders a list of collections" do
    render
    assert_select "tr>td", text: "Title".to_s, count: 2
    assert_select "tr>td", text: "Sort Title".to_s, count: 2
    assert_select "tr>td", text: "Subtitle".to_s, count: 2
    assert_select "tr>td", text: "Issn".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Inception".to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: 4.to_s, count: 2
  end
end
