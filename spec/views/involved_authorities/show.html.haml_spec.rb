require 'rails_helper'

RSpec.describe "involved_authorities/show", type: :view do
  before(:each) do
    @involved_authority = assign(:involved_authority, InvolvedAuthority.create!(
      authority: create(:person),
      role: InvolvedAuthority.roles[:illustrator],
      item: create(:work)
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/#{@involved_authority.authority.name}/)
    expect(rendered).to match(/illustrator/)
    expect(rendered).to match(/#{@involved_authority.item.title}/)
  end
end
