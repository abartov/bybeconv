require 'rails_helper'

describe 'bib/pubs_maybe_done.html.haml' do
  let(:maybe_done_pubs) {
    pubs = create_list(:publication, 3, :pubs_maybe_done)
    pubs.map { |p| [p, create_list(:manifestation, 1, author: p.person)] }
  }

  it 'renders' do
    assign(:pubs, maybe_done_pubs)
    render
  end
end