require 'rails_helper'

RSpec.describe "user_blocks/show", type: :view do
  before(:each) do
    @user_block = assign(:user_block, UserBlock.create!(
      user: nil,
      context: "Context",
      blocker_id: 2,
      reason: "Reason"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Context/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Reason/)
  end
end
