require 'rails_helper'

RSpec.describe "user_blocks/edit", type: :view do
  before(:each) do
    @user_block = assign(:user_block, UserBlock.create!(
      user: nil,
      context: "MyString",
      blocker_id: 1,
      reason: "MyString"
    ))
  end

  it "renders the edit user_block form" do
    render

    assert_select "form[action=?][method=?]", user_block_path(@user_block), "post" do

      assert_select "input[name=?]", "user_block[user_id]"

      assert_select "input[name=?]", "user_block[context]"

      assert_select "input[name=?]", "user_block[blocker_id]"

      assert_select "input[name=?]", "user_block[reason]"
    end
  end
end
