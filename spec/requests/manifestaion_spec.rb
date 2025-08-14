# frozen_string_literal: true

require 'rails_helper'

describe '/manifestation' do
  describe 'GET /manifestation/autocomplete_authority_name' do
    subject(:call) { get '/manifestation/autocomplete_authority_name?term=TeSt' }

    let(:match_1) { create(:authority, status: :published, name: 'First Test') }
    let(:match_2) { create(:authority, status: :published, name: 'X', other_designation: 'second_test') }
    let(:no_match_unpublished) { create(:authority, status: :unpublished, name: 'test 3') }
    let(:no_match_published) { create(:authority, status: :published, name: 'Y', other_designation: 'Z') }

    let(:expected_response) do
      [
        { 'id' => match_1.id.to_s, 'label' => match_1.name, 'value' => match_1.name },
        { 'id' => match_2.id.to_s, 'label' => match_2.name, 'value' => match_2.name }
      ]
    end

    before do
      Chewy.strategy(:atomic) do
        match_1
        match_2
        no_match_unpublished
        no_match_published
      end
    end

    after do
      Chewy.massacre
    end

    it 'returns a list of matching published authorities' do
      expect(call).to eq(200)
      expect(response.parsed_body).to eq(expected_response)
    end
  end
end
