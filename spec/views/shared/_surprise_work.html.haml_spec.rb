require 'rails_helper'

describe 'shared/_surprise_work.html.haml' do
  let(:manifestation) { create(:manifestation) }

  subject(:render_partial) { render partial: 'shared/surprise_work.html.haml', locals: { manifestation: manifestation, passed_mode: mode, id_frag: id_frag, passed_genre: genre, side: side } }

  let(:id_frag) { '1' }
  let(:side) { '1' }
  let(:mode) { 'home' }
  let(:genre) { 'article' }
  it 'renders' do
    render_partial
  end
end