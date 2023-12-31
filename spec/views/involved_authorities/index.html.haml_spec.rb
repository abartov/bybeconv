require 'rails_helper'

RSpec.describe "involved_authorities/index", type: :view do
  before(:each) do
    @involved_authorities = Kaminari.paginate_array([
      InvolvedAuthority.create!(
        authority: create(:person),
        role: InvolvedAuthority.roles[:illustrator],
        item: create(:work)
        ),
      InvolvedAuthority.create!(
        authority: create(:person),
        role: InvolvedAuthority.roles[:illustrator],
        item: create(:work)
        )
    ]).page(1)
    assign(:involved_authorities, @involved_authorities)
  end

  it "renders a list of involved_authorities" do
    render
    assert_select "tr>td", text: @involved_authorities.first.authority.name.to_s
    assert_select "tr>td", text: 'illustrator', count: 2
    assert_select "tr>td", text: @involved_authorities.last.item.title.to_s
  end
end
