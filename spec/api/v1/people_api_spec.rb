require 'rails_helper'

describe V1::PeopleAPI do
  include_context 'API Spec Helpers'

  describe 'GET api/v1/people/{id}' do
    let(:detail) { "metadata" }
    let(:person_id) { -1 }
    let(:path) { "/api/v1/people/#{person_id}?key=#{key}&author_detail=#{detail}" }
    let(:subject) { get path }

    include_context 'API Key Check'

    context 'when wrong id provided' do
      let(:person_id) { -1 }
      it 'fails with Not Found status' do
        expect(subject).to eq 404
        expect(error_message).to eq "Couldn't find Person with 'id'=-1"
      end
    end

    context 'when correct id provided' do
      let!(:original_manifestation) { create(:manifestation, author: person) }
      let!(:translated_manifestation) { create(:manifestation, translator: person, orig_lang: 'ru') }
      let!(:edited_manifestation) { create(:manifestation, editor: person) }
      let!(:illustrated_manifestation) { create(:manifestation, illustrator: person) }
      let!(:manifestation_about) do
        m = create(:manifestation)
        create(:aboutness, aboutable: person, work: m.expression.work)
        m
      end
      let(:person) do
        create(:person)
      end
      let(:person_id) { person.id }

      context 'when no details param provided' do
        let(:path) { "/api/v1/people/#{person_id}?key=#{key}" }

        it "returns personal  metadata" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'metadata')
        end
      end

      context 'when metadata details requested' do
        let(:detail) { 'metadata' }
        it "returns personal  metadata" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'metadata')
          expect(json_response['texts']).to be_nil
          expect(json_response['enrichment']).to be_nil
        end
      end

      context 'when texts details requested' do
        let(:detail) { 'texts' }
        it "returns a list of IDs of the works this person was involved in, with their role in each" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'texts')
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
        it "returns personal metadata plus texts he was involved into, plus texts about this person (backlinks)" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'enriched')
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

  def validate_person(json, person, detail)
    expect(json['id']).to eq person.id
    expect(json['url']).to eq Rails.application.routes.url_helpers.bib_person_url(person)
    metadata = json['metadata']
    expect(metadata).to_not be_nil
    expect(metadata['name']).to eq(person.name)
    expect(metadata['sort_name']).to eq(person.sort_name)
    expect(metadata['birth_year']).to eq(person.birth_year)
    expect(metadata['death_year']).to eq(person.death_year)
    expect(metadata['gender']).to eq(person.gender)
    expect(metadata['copyright_status']).to eq(!person.public_domain?)
    expect(metadata['period']).to eq(person.period)

    if %w(texts enriched).include?(detail)
      texts = json['texts']
      expect(texts).to_not be_nil
      expect(texts).to have_key('author')
      expect(texts).to have_key('translator')
      expect(texts).to have_key('editor')
    else
      expect(metadata).to_not have_key('texts')
    end

    expect(metadata['other_designations']).to eq(person.other_designation)
    expect(metadata['bio_snippet']).to eq(person.wikipedia_snippet)
    expect(metadata['languages']).to eq(person.all_languages)
    expect(metadata['genres']).to eq(person.all_genres)
    expect(metadata['impressions_count']).to eq(person.impressions_count)

    if detail == 'enriched'
      enrichment = json['enrichment']
      expect(enrichment).to_not be_nil
      expect(enrichment['texts_about']).to_not be_nil
    else
      expect(json).to_not have_key('enrichment')
    end
  end
end
