require 'rails_helper'

RSpec.describe "involved_authorities/edit", type: :view do
  before(:each) do
    @involved_authority = assign(:involved_authority, InvolvedAuthority.create!(
      authority: create(:person),
      role: 1,
      item: create(:work)
    ))
  end

  it "renders the edit involved_authority form" do
    render

    assert_select "form[action=?][method=?]", involved_authority_path(@involved_authority), "post" do

      assert_select "input[name=?]", "involved_authority[authority]"

      assert_select "input[name=?]", "involved_authority[role]"

      assert_select "input[name=?]", "involved_authority[item]"
    end
  end
end
