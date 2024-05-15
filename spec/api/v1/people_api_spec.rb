require 'rails_helper'

describe V1::PeopleAPI do
  include_context 'API Spec Helpers'

  describe 'GET api/v1/people/{id}' do
    subject(:call) { get path }

    let(:detail) { 'metadata' }
    let(:authority_id) { -1 }
    let(:path) { "/api/v1/people/#{authority_id}?key=#{key}&author_detail=#{detail}" }

    include_context 'API Key Check'

    context 'when wrong id provided' do
      let(:authority_id) { -1 }

      it 'fails with Not Found status' do
        expect(call).to eq 404
        expect(error_message).to eq "Couldn't find Authority with 'id'=-1"
      end
    end

    context 'when correct id provided' do
      let!(:original_manifestation) { create(:manifestation, author: authority) }
      let!(:translated_manifestation) { create(:manifestation, translator: authority, orig_lang: 'ru') }
      let!(:edited_manifestation) { create(:manifestation, editor: authority) }
      let!(:illustrated_manifestation) { create(:manifestation, illustrator: authority) }
      let!(:manifestation_about) do
        m = create(:manifestation)
        create(:aboutness, aboutable: authority, work: m.expression.work)
        m
      end
      let(:authority) { create(:authority) }
      let(:authority_id) { authority.id }

      context 'when no details param provided' do
        let(:path) { "/api/v1/people/#{authority_id}?key=#{key}" }

        it 'returns personal metadata' do
          expect(call).to eq 200
          validate_person(json_response, authority, 'metadata')
        end
      end

      context 'when metadata details requested' do
        let(:detail) { 'metadata' }
        it 'returns personal metadata' do
          expect(call).to eq 200
          validate_person(json_response, authority, 'metadata')
          expect(json_response['texts']).to be_nil
          expect(json_response['enrichment']).to be_nil
        end
      end

      context 'when texts details requested' do
        let(:detail) { 'texts' }
        it 'returns a list of IDs of the works this person was involved in, with their role in each' do
          expect(call).to eq 200
          validate_person(json_response, authority, 'texts')
          texts = json_response['texts']
          expect(texts['author']).to eq([original_manifestation.id])
          expect(texts['editor']).to eq([edited_manifestation.id])
          expect(texts['illustrator']).to eq([illustrated_manifestation.id])
          expect(texts['translator']).to eq([translated_manifestation.id])
          expect(json_response['enrichment']).to be_nil
        end
      end

      context 'when enriched details requested' do
        let(:detail) { 'enriched' }
        it 'returns personal metadata plus texts he was involved into, plus texts about this person (backlinks)' do
          expect(call).to eq 200
          validate_person(json_response, authority, 'enriched')
          texts = json_response['texts']
          expect(texts['author']).to eq([original_manifestation.id])
          expect(texts['editor']).to eq([edited_manifestation.id])
          expect(texts['illustrator']).to eq([illustrated_manifestation.id])
          expect(texts['translator']).to eq([translated_manifestation.id])
          expect(json_response['enrichment']['texts_about']).to eq([manifestation_about.id])
        end
      end
    end
  end

  def validate_person(json, authority, detail)
    expect(json['id']).to eq authority.id
    expect(json['url']).to eq Rails.application.routes.url_helpers.bib_person_url(authority)
    metadata = json['metadata']
    expect(metadata).to_not be_nil
    expect(metadata['name']).to eq(authority.name)
    expect(metadata['sort_name']).to eq(authority.sort_name)
    expect(metadata['birth_year']).to eq(authority.person.birth_year)
    expect(metadata['death_year']).to eq(authority.person.death_year)
    expect(metadata['gender']).to eq(authority.person.gender)
    expect(metadata['intellectual_property']).to eq(authority.intellectual_property)
    expect(metadata['period']).to eq(authority.person.period)

    if %w(texts enriched).include?(detail)
      texts = json['texts']
      expect(texts).to_not be_nil
      expect(texts).to have_key('author')
      expect(texts).to have_key('translator')
      expect(texts).to have_key('editor')
    else
      expect(metadata).to_not have_key('texts')
    end

    expect(metadata['other_designations']).to eq(authority.other_designation)
    expect(metadata['bio_snippet']).to eq(authority.wikipedia_snippet)
    expect(metadata['languages']).to eq(authority.all_languages)
    expect(metadata['genres']).to eq(authority.all_genres)
    expect(metadata['impressions_count']).to eq(authority.impressions_count)

    if detail == 'enriched'
      enrichment = json['enrichment']
      expect(enrichment).to_not be_nil
      expect(enrichment['texts_about']).to_not be_nil
    else
      expect(json).to_not have_key('enrichment')
    end
  end
end
