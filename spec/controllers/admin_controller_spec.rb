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
end