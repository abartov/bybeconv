require 'rails_helper'

RSpec.describe "user_blocks/new", type: :view do
  before(:each) do
    assign(:user_block, UserBlock.new(
      user: nil,
      context: "MyString",
      blocker_id: 1,
      reason: "MyString"
    ))
  end

  it "renders new user_block form" do
    render

    assert_select "form[action=?][method=?]", user_blocks_path, "post" do

      assert_select "input[name=?]", "user_block[user_id]"

      assert_select "input[name=?]", "user_block[context]"

      assert_select "input[name=?]", "user_block[blocker_id]"

      assert_select "input[name=?]", "user_block[reason]"
    end
  end
end
