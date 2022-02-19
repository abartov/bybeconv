require 'rails_helper'

describe 'admin/suspicious_titles.html.haml' do
  it 'renders' do
    assign(:suspicious, create_list(:manifestation, 3))
    render
  end
end