require 'rails_helper'

RSpec.describe "collections/show", type: :view do
  before(:each) do
    @collection = assign(:collection, Collection.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Sort Title/)
    expect(rendered).to match(/Subtitle/)
    expect(rendered).to match(/Issn/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Inception/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/4/)
  end
end
