require 'rails_helper'

describe V1::PeopleAPI do
  include_context 'API Spec Helpers'

  describe 'GET api/v1/people/{id}' do
    let(:detail) { 'metadata' }
    let(:person_id) { -1 }
    let(:path) { "/api/v1/people/#{person_id}?key=#{key}&authorDetail=#{detail}" }
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
      let!(:manifestation_about) do
        m = create(:manifestation)
        create(:aboutness, aboutable: person, work: m.expressions[0].works[0])
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
          expect(json_response['metadata']['work_ids']).to be_nil
          expect(json_response['enrichment']).to be_nil
        end
      end

      context 'when enriched details requested' do
        let(:detail) { 'enriched' }
        it "returns personal metadata plus works about this person (backlinks)" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'enriched')
          expect(json_response['metadata']['work_ids']).to be_nil
          expect(json_response['enrichment']['works_about']).to eq([manifestation_about.id])
        end
      end

      context 'when works details requested' do
        let(:detail) { 'works' }
        it "returns a list of IDs of the works this person was involved in, with their role in each" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'works')
          expect(json_response['metadata']['work_ids']).to eq([original_manifestation.id, translated_manifestation.id])
          expect(json_response['enrichment']).to be_nil
        end
      end

      context 'when original_works details requested' do
        let(:detail) { 'original_works' }
        it "returns a list of IDs of the works where this person is the original author" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'original_works')
          expect(json_response['metadata']['work_ids']).to eq([original_manifestation.id])
          expect(json_response['enrichment']).to be_nil
        end
      end

      context 'when translations details requested' do
        let(:detail) { 'translations' }
        it "returns a list of IDs of the works where this person translated" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'translations')
          expect(json_response['metadata']['work_ids']).to eq([translated_manifestation.id])
          expect(json_response['enrichment']).to be_nil
        end
      end

      context 'when full details requested' do
        let(:detail) { 'full' }
        it "returns enriched metadata plus all works" do
          expect(subject).to eq 200
          validate_person(json_response, person, 'full')
          expect(json_response['metadata']['work_ids']).to eq([original_manifestation.id, translated_manifestation.id])
          expect(json_response['enrichment']['works_about']).to eq([manifestation_about.id])
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

    if %w(metadata enriched).include?(detail)
      expect(metadata).to_not have_key('work_ids')
    else
      work_ids = metadata['work_ids']
      expect(work_ids).to_not be_nil
    end

    expect(metadata['other_designations']).to eq(person.other_designation)
    expect(metadata['bio_snippet']).to eq(person.wikipedia_snippet)
    expect(metadata['languages']).to eq(person.all_languages)
    expect(metadata['genres']).to eq(person.all_genres)
    expect(metadata['impressions_count']).to eq(person.impressions_count)
    if %w(full enriched).include? detail
      enrichment = json['enrichment']
      expect(enrichment).to_not be_nil
      expect(enrichment['works_about']).to_not be_nil
    else
      expect(json).to_not have_key('enrichment')
    end
  end
end