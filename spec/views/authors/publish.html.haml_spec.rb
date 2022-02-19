require 'rails_helper'

describe 'authors/publish.html.haml' do
  let(:author) { create(:person) }
  let(:manifestations) { create_list(:manifestation, 3, author: author) }

  before do
    assign(:author, author)
    assign(:manifestations, manifestations)
  end

  it 'renders' do
    render
  end
end