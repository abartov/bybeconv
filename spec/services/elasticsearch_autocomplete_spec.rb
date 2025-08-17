# frozen_string_literal: true

require 'rails_helper'

describe ElasticsearchAutocomplete do
  subject(:call) { described_class.call(term, index_class, fields, filter: filter) }

  let(:index_class) { AuthoritiesAutocompleteIndex }
  let(:returned_ids) { call.map(&:id) }
  let(:fields) { %i(name other_designation) }

  let(:match_1) { create(:authority, status: :published, name: 'First Test') }
  let(:match_2) { create(:authority, status: :published, name: 'X', other_designation: 'second test') }
  let(:match_3) { create(:authority, status: :unpublished, name: 'test 3') }
  let(:no_match) { create(:authority, status: :published, name: 'Y', other_designation: 'Z') }
  let(:filter) { nil }

  before do
    Chewy.strategy(:atomic) do
      match_1
      match_2
      match_3
      no_match
    end
  end

  after do
    Chewy.massacre
  end

  context 'when term is blank' do
    let(:term) { '  ' }

    it { is_expected.to be_empty }
  end

  context 'when term is provided' do
    let(:term) { 'TeSt' }

    it 'returns matching records' do
      expect(returned_ids).to contain_exactly(match_1.id, match_2.id, match_3.id)
    end

    context 'when filter by published status is provided' do
      let(:filter) { { term: { published: true } } }

      it 'returns matching published records' do
        expect(returned_ids).to contain_exactly(match_1.id, match_2.id)
      end
    end

    context 'when term contains whitespaces' do
      let(:term) { 'second t' }

      it 'returns matching records' do
        expect(returned_ids).to contain_exactly(match_2.id)
      end
    end

    context 'when only one field provided' do
      let(:fields) { [:name] }

      it 'returns matching records using only one field' do
        expect(returned_ids).to contain_exactly(match_1.id, match_3.id)
      end
    end
  end
end
