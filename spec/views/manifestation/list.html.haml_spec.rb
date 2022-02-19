require 'rails_helper'

describe 'manifestation/list.html.haml' do
  before do
    create_list(:manifestation, 3)
    session[:mft_q_params] = { title: '', author: '' }
    assign(:manifestations, Manifestation.all_published.page(0))
  end

  it 'renders' do
    render
  end
end