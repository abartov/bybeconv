require 'rails_helper'

RSpec.describe "involved_authorities/new", type: :view do
  before(:each) do
    assign(:involved_authority, InvolvedAuthority.new(
      authority: create(:person),
      role: 1,
      item: create(:work)
    ))
  end

  it "renders new involved_authority form" do
    render

    assert_select "form[action=?][method=?]", involved_authorities_path, "post" do

      assert_select "input[name=?]", "involved_authority[authority]"

      assert_select "input[name=?]", "involved_authority[role]"

      assert_select "input[name=?]", "involved_authority[item]"
    end
  end
end
