require 'rails_helper'

RSpec.describe "ingestibles/index", type: :view do
  before(:each) do
    assign(:ingestibles, [
      Ingestible.create!(
        title: "Title",
        status: 2,
        defaults: "MyText",
        metadata: "MyText",
        comments: "MyText",
        markdown: "MyText"
      ),
      Ingestible.create!(
        title: "Title",
        status: 2,
        defaults: "MyText",
        metadata: "MyText",
        comments: "MyText",
        markdown: "MyText"
      )
    ])
  end

  it "renders a list of ingestibles" do
    render
    assert_select "tr>td", text: "Title".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
  end
end
