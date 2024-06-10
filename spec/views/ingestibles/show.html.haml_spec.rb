require 'rails_helper'

RSpec.describe "ingestibles/show", type: :view do
  before(:each) do
    @ingestible = assign(:ingestible, Ingestible.create!(
      title: "Title",
      status: 2,
      defaults: "MyText",
      metadata: "MyText",
      comments: "MyText",
      markdown: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
  end
end
