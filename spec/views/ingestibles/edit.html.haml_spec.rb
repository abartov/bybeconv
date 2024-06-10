require 'rails_helper'

RSpec.describe "ingestibles/edit", type: :view do
  before(:each) do
    @ingestible = assign(:ingestible, Ingestible.create!(
      title: "MyString",
      status: 1,
      defaults: "MyText",
      metadata: "MyText",
      comments: "MyText",
      markdown: "MyText"
    ))
  end

  it "renders the edit ingestible form" do
    render

    assert_select "form[action=?][method=?]", ingestible_path(@ingestible), "post" do

      assert_select "input[name=?]", "ingestible[title]"

      assert_select "input[name=?]", "ingestible[status]"

      assert_select "textarea[name=?]", "ingestible[defaults]"

      assert_select "textarea[name=?]", "ingestible[metadata]"

      assert_select "textarea[name=?]", "ingestible[comments]"

      assert_select "textarea[name=?]", "ingestible[markdown]"
    end
  end
end
