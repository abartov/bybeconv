require 'rails_helper'

RSpec.describe "involved_authorities/index", type: :view do
  before(:each) do
    assign(:involved_authorities, [
      InvolvedAuthority.create!(
        authority: nil,
        role: 2,
        item: nil
      ),
      InvolvedAuthority.create!(
        authority: nil,
        role: 2,
        item: nil
      )
    ])
  end

  it "renders a list of involved_authorities" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
