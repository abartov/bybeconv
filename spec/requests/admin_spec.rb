# frozen_string_literal: true

require 'rails_helper'

describe '/admin' do
  describe 'GET /autocomplete_authority_name_and_aliases' do
    subject(:call) { get '/autocomplete_authority_name_and_aliases?term=TeSt' }

    let(:match_1) { create(:authority, status: :published, name: 'First Test') }
    let(:match_2) { create(:authority, status: :published, name: 'X', other_designation: 'second_test') }
    let(:match_3) { create(:authority, status: :unpublished, name: 'test 3') }
    let(:no_match) { create(:authority, status: :published, name: 'Y', other_designation: 'Z') }

    let(:expected_response) do
      [
        { 'id' => match_1.id.to_s, 'label' => match_1.name, 'value' => match_1.name },
        { 'id' => match_2.id.to_s, 'label' => match_2.name, 'value' => match_2.name },
        { 'id' => match_3.id.to_s, 'label' => match_3.name, 'value' => match_3.name }
      ]
    end

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

    context 'when user is not authenticated' do
      it { is_expected.to eq(302) }
    end

    context 'when user is authenticated and has editor permissions' do
      let(:user) { create(:user, editor: true) }

      before do
        controller = AdminController.new
        allow(controller).to receive(:current_user).and_return(user)
        allow(AdminController).to receive(:new).and_return(controller)
      end

      it 'returns a list of matching authorities including not published' do
        expect(call).to eq(200)
        expect(response.parsed_body).to eq(expected_response)
      end
    end
  end

  describe 'GET /autocomplete_manifestation_title' do
    subject(:call) { get '/autocomplete_manifestation_title?term=TeSt' }

    let(:match_1) { create(:manifestation, status: :published, title: 'First Test') }
    let(:match_2) { create(:manifestation, status: :published, title: 'X', alternate_titles: 'second_test') }
    let(:match_3) { create(:manifestation, status: :nonpd, title: 'test 3') }
    let(:no_match) { create(:manifestation, status: :published, title: 'Y', alternate_titles: 'Z') }

    let(:expected_response) do
      [
        {
          'id' => match_1.id.to_s,
          'label' => match_1.title_and_authors,
          'value' => match_1.title_and_authors,
          'expression_id' => match_1.expression_id
        },
        {
          'id' => match_2.id.to_s,
          'label' => match_2.title_and_authors,
          'value' => match_2.title_and_authors,
          'expression_id' => match_2.expression_id
        },
        {
          'id' => match_3.id.to_s,
          'label' => match_3.title_and_authors,
          'value' => match_3.title_and_authors,
          'expression_id' => match_3.expression_id
        }
      ]
    end

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

    context 'when user is not authenticated' do
      it { is_expected.to eq(302) }
    end

    context 'when user is authenticated and has editor permissions' do
      let(:user) { create(:user, editor: true) }

      before do
        controller = AdminController.new
        allow(controller).to receive(:current_user).and_return(user)
        allow(AdminController).to receive(:new).and_return(controller)
      end

      it 'returns a list of matching authorities including not published' do
        expect(call).to eq(200)
        expect(response.parsed_body).to eq(expected_response)
      end
    end
  end
end
