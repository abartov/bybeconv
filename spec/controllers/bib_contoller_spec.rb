require 'rails_helper'

describe BibController do
  let(:user) { create(:user, :bib_workshop) }
  before do
    session[:user_id] = user.id
  end

  describe '#pubs_maybe_done' do
    subject(:request) { get :pubs_maybe_done }

    let!(:maybe_done_pubs) { create_list(:publication, 3, :pubs_maybe_done) }
    let!(:other_pubs) { create_list(:publication, 2) }

    it 'renders all publications where pubs_maybe_done list item present' do
      expect(request).to be_successful
      expect(assigns(:pubs)).to match_array(maybe_done_pubs.map { |pub| [pub, []]})
    end
  end
end
