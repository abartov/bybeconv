require 'rails_helper'

=begin RSpec.describe "user_blocks/index", type: :view do
  before(:each) do
    assign(:user_blocks, [
      UserBlock.create!(
        user: nil,
        context: "Context",
        blocker_id: 2,
        reason: "Reason"
      ),
      UserBlock.create!(
        user: nil,
        context: "Context",
        blocker_id: 2,
        reason: "Reason"
      )
    ])
  end

  it "renders a list of user_blocks" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Context".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Reason".to_s, count: 2
  end
end
=end