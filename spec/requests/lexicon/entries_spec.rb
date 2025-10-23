# frozen_string_literal: true

require 'rails_helper'

describe '/lexicon/entries' do
  describe 'routing' do
    it { expect(get: '/lex/entries/1/edit').to route_to('lexicon/entries#edit', id: '1') }
  describe '#index' do
    subject { get '/lex/entries' }

    before do
      create_list(:lex_entry, 2, :person)
      create_list(:lex_entry, 2, :publication)
    end

    it { is_expected.to eq(200) }
  end

  describe '#show' do
    subject { get "/lex/entries/#{entry.id}" }

    context 'when entry is a Person' do
      let(:entry) { create(:lex_entry, :person, status: :migrated) }
      let(:authority) { create(:authority) }

      it { is_expected.to eq(200) }

      context 'when entry has authority' do
        before do
          entry.lex_item.update!(authority_id: authority.id)
        end

        it { is_expected.to eq(200) }
      end
    end

    context 'when entry is a Publication' do
      let(:entry) { create(:lex_entry, :publication) }

      it { is_expected.to eq(200) }
    end
  end

  describe '#edit' do
    subject(:call) { get "/lex/entries/#{entry.id}/edit", params: { tab: tab } }
    let(:tab) { nil }
    
    shared_examples 'successful response' do
      it 'renders edit template' do
        expect(call).to eq(200)
        expect(response).to render_template(:edit)
      end
    end

    context 'when entry is a Person' do
      let(:entry) { create(:lex_entry, :person) }

      context 'without tab parameter' do
        it_behaves_like 'successful response'

        it 'assigns properties as active tab' do
          call
          expect(assigns(:active_tab)).to eq(:properties)
        end
      end

      context 'with tab parameter' do
        let(:tab) { 'citations' }

        it_behaves_like 'successful response'

        it 'assigns specified tab as active' do
          call
          expect(assigns(:active_tab)).to eq(:citations)
        end
      end
    end

    context 'when entry is a Publication' do
      let(:entry) { create(:lex_entry, :publication) }
      
      context 'without tab parameter' do
        it_behaves_like 'successful response'

        it 'assigns properties as active tab' do
          call
          expect(assigns(:active_tab)).to eq(:properties)
        end
      end
    end
  end
end
