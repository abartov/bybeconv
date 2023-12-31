require 'rails_helper'

RSpec.describe "corporate_bodies/index", type: :view do
  before(:each) do
    assign(:corporate_bodies, [
      CorporateBody.create!(
        name: "Name",
        alternate_names: "Alternate Names",
        location: "Location",
        inception: "Inception",
        inception_year: 2,
        dissolution: "Dissolution",
        dissolution_year: 3,
        wikidata_uri: "Wikidata Uri",
        viaf_id: "Viaf",
        comments: "MyText"
      ),
      CorporateBody.create!(
        name: "Name",
        alternate_names: "Alternate Names",
        location: "Location",
        inception: "Inception",
        inception_year: 2,
        dissolution: "Dissolution",
        dissolution_year: 3,
        wikidata_uri: "Wikidata Uri",
        viaf_id: "Viaf",
        comments: "MyText"
      )
    ])
  end

  it "renders a list of corporate_bodies" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "Alternate Names".to_s, count: 2
    assert_select "tr>td", text: "Location".to_s, count: 2
    assert_select "tr>td", text: "Inception".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Dissolution".to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: "Wikidata Uri".to_s, count: 2
    assert_select "tr>td", text: "Viaf".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
  end
end
