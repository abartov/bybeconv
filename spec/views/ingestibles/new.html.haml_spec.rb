require 'rails_helper'

RSpec.describe "ingestibles/new", type: :view do
  before(:each) do
    assign(:ingestible, Ingestible.new(
      title: "MyString",
      status: 1,
      defaults: "MyText",
      metadata: "MyText",
      comments: "MyText",
      markdown: "MyText"
    ))
  end

  it "renders new ingestible form" do
    render

    assert_select "form[action=?][method=?]", ingestibles_path, "post" do

      assert_select "input[name=?]", "ingestible[title]"

      assert_select "input[name=?]", "ingestible[status]"

      assert_select "textarea[name=?]", "ingestible[defaults]"

      assert_select "textarea[name=?]", "ingestible[metadata]"

      assert_select "textarea[name=?]", "ingestible[comments]"

      assert_select "textarea[name=?]", "ingestible[markdown]"
    end
  end
end
