require 'rails_helper'

describe AdminController do
  describe '#missing_genre' do
    subject { get :missing_genres }

    include_context 'Unauthorized access to admin page'

    context 'when admin user is authorized' do
      include_context 'Admin user logged in'

      it { is_expected.to be_successful }
    end
  end

  describe '#suspicious_headings' do
    subject { get :suspicious_headings }

    include_context 'Admin user logged in'

    before do
      create(:manifestation, cached_heading_lines: '1|2|3|4', markdown: "Some\nmultiline\ntext\nfor\n\test")
    end

    it { is_expected.to be_successful }
  end

  describe '#suspicious_titles' do
    subject { get :suspicious_titles }

    include_context 'Admin user logged in'

    before do
      create(:manifestation, cached_heading_lines: '1|2|3|4', markdown: "Some\nmultiline\ntext\nfor\n\test")
    end

    it { is_expected.to be_successful }
  end

  describe '#incongruous_copyright' do
    include_context 'Admin user logged in'
    subject(:request) { get :incongruous_copyright }

    let(:copyrighted_person) { create(:person, public_domain: false) }

    let!(:public_domain_manifestation) { create(:manifestation, copyrighted: false) }
    let!(:copyrighted_manifestation) { create(:manifestation, author: copyrighted_person, copyrighted: true) }
    let!(:wrong_public_domain_manifestation_1) { create(:manifestation, author: copyrighted_person, copyrighted: false) }
    let!(:wrong_public_domain_manifestation_2) { create(:manifestation, orig_lang: 'ru', translator: copyrighted_person, copyrighted: false) }
    let!(:wrong_copyrighted_manifestation_1) { create(:manifestation, copyrighted: true) }
    let!(:wrong_copyrighted_manifestation_2) { create(:manifestation, orig_lang: 'ru', copyrighted: true) }

    let(:wrong_manifestation_ids) {
      [
        wrong_public_domain_manifestation_1.id,
        wrong_public_domain_manifestation_2.id,
        wrong_copyrighted_manifestation_1.id,
        wrong_copyrighted_manifestation_2.id
      ]
    }

    it 'renders successfully' do
      expect(request).to be_successful
      expect(assigns(:incong).map(&:first).map(&:id)).to match_array wrong_manifestation_ids
    end
  end
end