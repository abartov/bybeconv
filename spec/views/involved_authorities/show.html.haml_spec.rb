require 'rails_helper'

RSpec.describe "involved_authorities/show", type: :view do
  before(:each) do
    @involved_authority = assign(:involved_authority, InvolvedAuthority.create!(
      authority: nil,
      role: 2,
      item: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
