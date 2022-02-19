require 'rails_helper'

describe 'manifestation/_surprise_work.html.haml' do
  let(:manifestation) { create(:manifestation) }

  it 'renders' do
    render partial: 'manifestation/surprise_work.html.haml', locals: { work: manifestation }
  end
end