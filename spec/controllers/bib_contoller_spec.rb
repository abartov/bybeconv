require 'rails_helper'

describe BibController do
  let(:user) { create(:user, :bib_workshop) }
  before do
    session[:user_id] = user.id
  end

  describe '#pubs_maybe_done' do
    subject(:request) { get :pubs_maybe_done }

    let!(:original_maybe_done_pub) { create(:publication, :pubs_maybe_done, title: 'original title') }
    let!(:original_manifestation) { create(:manifestation, title: "#{original_maybe_done_pub.title} manifestation", author: original_maybe_done_pub.person)}

    let!(:translated_maybe_done_pub) { create(:publication, :pubs_maybe_done, title: 'translated title') }
    let!(:translated_manifestation_1) { create(:manifestation, title: "#{translated_maybe_done_pub.title} manifestation 1", orig_lang: 'ru', translator: translated_maybe_done_pub.person)}
    let!(:translated_manifestation_2) { create(:manifestation, title: "#{translated_maybe_done_pub.title} manifestation 2", orig_lang: 'ru', translator: translated_maybe_done_pub.person)}

    let!(:other_pubs) { create_list(:publication, 2) }

    it 'renders all publications where pubs_maybe_done list item present' do
      expect(request).to be_successful
      expect(assigns(:pubs)).to match_array [
        [original_maybe_done_pub, [original_manifestation]],
        [translated_maybe_done_pub, [translated_manifestation_1, translated_manifestation_2]]
      ]
    end
  end
end
