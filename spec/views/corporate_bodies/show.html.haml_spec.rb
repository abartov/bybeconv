require 'rails_helper'

RSpec.describe "corporate_bodies/show", type: :view do
  before(:each) do
    @corporate_body = assign(:corporate_body, CorporateBody.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Alternate Names/)
    expect(rendered).to match(/Location/)
    expect(rendered).to match(/Inception/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Dissolution/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Wikidata Uri/)
    expect(rendered).to match(/Viaf/)
    expect(rendered).to match(/MyText/)
  end
end
