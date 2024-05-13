# frozen_string_literal: true

require 'rails_helper'

describe HtmlFile do
  describe '.create_WEM_new' do
    subject(:call) { html_file.create_WEM_new(author.id, title, markdown, true) }

    let(:html_file) { create(:html_file, status: status) }
    let(:author) { html_file.person }
    let(:translator) { html_file.translator }
    let(:markdown) { 'TEST' }
    let(:title) { '   TITLE WITH WHITESPACES ' }

    context 'when file is not accepted' do
      let(:status) { 'Unknown' }

      it { is_expected.to eq I18n.t(:must_accept_before_publishing) }
    end

    context 'when file is accepted' do
      let(:status) { 'Accepted' }

      let(:manifestation) { Manifestation.order(id: :desc).first }

      it 'creates WEM structure' do
        expect { call }.to change(Manifestation, :count).by(1)
                                                        .and change(Expression, :count).by(1)
                                                        .and change(Work, :count).by(1)
                                                        .and change(Creation, :count).by(1)
                                                        .and change(Realizer, :count).by(1)
        expect(manifestation.authors).to eq [author]
        expect(manifestation.translators).to eq [translator]
        expect(manifestation).to have_attributes(
          title: 'TITLE WITH WHITESPACES', # whitespaces stripped
          authors: [author],
          translators: [translator]
        )
      end
    end
  end
end
