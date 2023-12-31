require 'rails_helper'

RSpec.describe "involved_authorities/edit", type: :view do
  before(:each) do
    @involved_authority = assign(:involved_authority, InvolvedAuthority.create!(
      authority: nil,
      role: 1,
      item: nil
    ))
  end

  it "renders the edit involved_authority form" do
    render

    assert_select "form[action=?][method=?]", involved_authority_path(@involved_authority), "post" do

      assert_select "input[name=?]", "involved_authority[authority_id]"

      assert_select "input[name=?]", "involved_authority[role]"

      assert_select "input[name=?]", "involved_authority[item_id]"
    end
  end
end
