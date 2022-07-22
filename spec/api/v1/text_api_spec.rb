require 'rails_helper'

describe V1::TextsAPI do
  include_context 'API Spec Helpers'

  before do
    clean_tables
    Chewy.strategy(:atomic) do
      manifestation_1
      manifestation_2
      unpublished_manifestation
    end
  end

  let(:tag_popular) { create(:tag, name: :popular) }
  let(:tag_unpopular) { create(:tag, name: :unpopular) }
  let(:tag_pending) { create(:tag, name: :pending, status: :pending) }

  let(:total_count) { json_response['total_count'] }
  let(:data) { json_response['data'] }
  let(:data_ids) { data.map { |rec| rec['id'] } }

  let(:manifestation_1) do
    create(
      :manifestation, :with_recommendations, :with_external_links,
      title: '1st',
      impressions_count: 3,
      markdown: 'Sample Text 1',
      taggings: [ create(:tagging, tag: tag_popular),  create(:tagging, tag: tag_pending) ]
    )
  end

  let(:manifestation_2) do
    m = create(
      :manifestation, :with_recommendations, :with_external_links,
      title: '2nd',
      impressions_count: 2,
      markdown: 'Sample Text 2',
      taggings: [ create(:tagging, tag: tag_unpopular), create(:tagging, tag: tag_pending) ]
    )

    create(:aboutness, work: m.expression.work, aboutable: manifestation_1.expression.work)
    m
  end

  let(:unpublished_manifestation) do
    create(:manifestation, status: :unpublished)
  end

  describe 'GET /api/v1/texts/{id}' do
    let(:manifestation_id) { manifestation_1.id }
    let(:additional_params) { "" }
    let(:path) { "/api/v1/texts/#{manifestation_id}?key=#{key}#{additional_params}" }
    let(:subject) { get path }

    include_context 'API Key Check'

    context 'when wrong text_id is given' do
      let(:manifestation_id) { -1 }
      it 'fails with not_found status' do
        expect(subject).to eq 404
        expect(error_message).to eq 'Could not find documents for ids: -1'
      end
    end

    context 'when id of unpublished text is given' do
      let(:manifestation_id) { unpublished_manifestation.id }
      it 'fails with not_found status' do
        expect(subject).to eq 404
        expect(error_message).to eq "Could not find documents for ids: #{manifestation_id}"
      end
    end

    context 'when no additional params given' do
      it 'succeed and returns basic view and html file_format and without snippet' do
        expect(subject).to eq 200
        assert_manifestation(json_response, manifestation_1, 'basic', 'html', false)
      end
    end

    context 'when additional params given' do
      let(:additional_params) { "&view=#{view}&file_format=#{file_format}&snippet=#{snippet}" }

      context 'when basic view, epub format, with snippet are requested' do
        let(:view) { :basic }
        let(:file_format) { :epub }
        let(:snippet) { true }

        it 'completes successfully' do
          expect(subject).to eq 200
          assert_manifestation(json_response, manifestation_1, 'basic', 'epub', true)
        end
      end

      context 'when metadata view, pdf format, without snippet are requested' do
        let(:view) { :metadata }
        let(:file_format) { :pdf }
        let(:snippet) { false }

        it 'completes successfully' do
          expect(subject).to eq 200
          assert_manifestation(json_response, manifestation_1, 'metadata', 'pdf', false)
        end
      end

      context 'when enriched view, txt format, without snippet are requested' do
        let(:view) { :enriched }
        let(:file_format) { :txt }
        let(:snippet) { false }

        it 'completes successfully' do
          expect(subject).to eq 200
          assert_manifestation(json_response, manifestation_1, 'enriched', 'txt', false)
          # ensuring non-published tags are excluded
          assert_equal %w(popular), json_response['enrichment']['taggings']
          # ensuring works_about works correctly
          expect(json_response['enrichment']['texts_about']).to eq [ manifestation_2.id ]
        end
      end
    end
  end

  describe 'POST /api/v1/texts/batch' do
    let(:ids) { [manifestation_1.id, manifestation_2.id] }
    let(:params) {
      {
        key: key,
        ids: ids
      }.merge(additional_params)
    }
    let(:additional_params) { {} }
    let(:subject) { post '/api/v1/texts/batch', params: params }

    include_context 'API Key Check'

    context 'when single id specified' do
      let(:ids) { [manifestation_1.id] }

      it 'succeed and returns basic view in html format and without snippet' do
        expect(subject).to eq 201
        assert_equal 1, json_response.size
        assert_manifestation(json_response[0], manifestation_1, 'basic', 'html', false)
      end
    end

    context 'when multiple ids without additional_params specified' do
      it 'succeed and returns basic view in html format and without snippet' do
        expect(subject).to eq 201
        assert_equal 2, json_response.size
        assert_manifestation(json_response[0], manifestation_1, 'basic', 'html', false)
        assert_manifestation(json_response[1], manifestation_2, 'basic', 'html', false)
      end
    end

    context 'when multiple ids with additional params specified' do
      let(:additional_params) {
        {
          view: :enriched,
          file_format: :odt,
          snippet: true
        }
      }

      it 'completes successfully' do
        expect(subject).to eq 201
        assert_equal 2, json_response.size
        assert_manifestation(json_response[0], manifestation_1, 'enriched', 'odt', true)
        assert_manifestation(json_response[1], manifestation_2, 'enriched', 'odt', true)
      end
    end

    context 'when more than 25 ids are specified' do
      let(:ids) { (1..26).to_a }
      it 'fails with bad_request status' do
        expect(subject).to eq 400
        expect(error_message).to eq 'ids must have up to 25 items'
      end
    end

    context 'when some of provided text ids is not published' do
      let(:ids) { [manifestation_1.id, manifestation_2.id, unpublished_manifestation.id] }
      it 'fails with not_found status' do
        expect(subject).to eq 404
        expect(error_message).to eq "Could not find documents for ids: #{unpublished_manifestation.id}"
      end
    end
  end

  describe 'POST /api/v1/search' do
    let(:params) { { key: key, page: page }.merge(additional_params) }
    let(:additional_params) { {} }
    let(:page) { 1 }
    let(:subject) { post '/api/v1/search', params: params }

    include_context 'API Key Check'

    context 'when 1st page with no additional params specified' do
      it 'returns 1st page with basic view, html format and without snippet sorted alphabetically in asc order' do
        expect(subject).to eq 201
        expect(total_count).to eq 2
        expect(data.size).to eq 2
        assert_manifestation(data[0], manifestation_1, 'basic', 'html', false)
        assert_manifestation(data[1], manifestation_2, 'basic', 'html', false)
      end
    end

    context 'when 1st page with descending alphabetical sorting, enriched view, odt format and snippet' do
      let(:additional_params) {
        {
          sort_by: :alphabetical,
          sort_dir: :desc,
          view: :enriched,
          file_format: :odt,
          snippet: true
        }
      }
      it 'completes successfully' do
        expect(subject).to eq 201
        expect(total_count).to eq 2
        expect(data.size).to eq 2
        assert_manifestation(data[0], manifestation_2, 'enriched', 'odt', true)
        assert_manifestation(data[1], manifestation_1, 'enriched', 'odt', true)
      end
    end

    context 'when filter by copyright is provided' do
      let(:manifestations) {
        result = []
        (1..60).each do |index|
          e = create(:expression, copyrighted: index%10 == 0)
          result << create(:manifestation, impressions_count: Random.rand(100), expression: e)
        end
        result
      }
      before do
        clean_tables
        Chewy.strategy(:atomic) do
          manifestations
        end
      end

      let(:additional_params) { { is_copyrighted: true, sort_by: :popularity, sort_dir: :asc } }

      it 'returns only copyrighted works' do
        expect(subject).to eq 201
        expect(total_count).to eq 6
        expect(data.size).to eq 6
        expect(data_ids).to eq manifestations.select(&:copyright?).sort_by(&:impressions_count).map(&:id)
      end
    end

    context 'when complex filter is provided' do
      let(:all_filters) do
        {
          'genres' => %w(poetry),
          'periods' => %w(revival),
          'is_copyrighted' => true,
          'author_genders' => %w(male),
          'translator_genders' => %w(female),
          'title' => 'Title',
          'author' => 'Author',
          'fulltext' => 'Random Text',
          'author_ids' => [1, 2],
          'original_language' => 'ru',
          'uploaded_between' => { 'to' => 2016 },
          'created_between' => { 'from' => 1981, 'to' => 1986},
          'published_between' => { 'from' => 1990 }
        }
      end
      let(:additional_params) { { sort_by: :popularity, sort_dir: :asc }.merge(search_params) }

      let(:page) { 2 }

      let!(:records) do
        records = double('Search Result', count: 5)
        expect(records).to receive(:offset).with(25).and_return(records)
        expect(records).to receive(:limit).with(25).and_return(records)
        expect(records).to receive(:to_a).and_return([])
        records
      end

      let(:service_params) do
        result = search_params.reject { |k, _v| k == 'original_language' }
        orig_lang = search_params['original_language']
        if orig_lang.present?
          result['original_languages'] = [ orig_lang ]
        end
        result
      end

      context 'when fulltext param is provided' do
        let(:search_params) { all_filters }
        it 'passes all params to SearchManifestation service without sorting' do
          expect_any_instance_of(SearchManifestations).to receive(:call).with(nil, nil, service_params).and_return(records)
          expect(subject).to eq 201
          expect(total_count).to eq 5
          expect(data).to eq []
        end
      end

      context 'when no fulltext param is provided' do
        let(:search_params) { all_filters.reject { |k, _v| k == 'fulltext' } }
        it 'passes all params to SearchManifestation service with sorting' do
          expect_any_instance_of(SearchManifestations).to receive(:call).with('popularity', 'asc', service_params).and_return(records)
          expect(subject).to eq 201
          expect(total_count).to eq 5
          expect(data).to eq []
        end
      end
    end

    context 'when many pages exists' do
      before do
        clean_tables
        Chewy.strategy(:atomic) do
          create_list(:manifestation, 30)
        end
      end

      let(:additional_params) { { sort_by: :alphabetical, sort_dir: sort_dir } }
      let(:asc_order) { Manifestation.all_published.order(sort_title: :asc, id: :asc).pluck(:id) }

      context 'when 1st page in ascending order is requested' do
        let(:sort_dir) { :asc }
        it 'returns items from 0 to 24' do
          expect(subject).to eq 201
          expect(total_count).to eq 30
          expect(data_ids).to eq asc_order[0..24]
        end
      end

      context 'when 2nd page in ascending order is requested' do
        let(:sort_dir) { :asc }
        let(:page) { 2 }
        it 'returns items from 25 to 29' do
          expect(subject).to eq 201
          expect(total_count).to eq 30
          expect(data_ids).to eq asc_order[25..29]
        end
      end

      context 'when 3rd page in ascending order is requested' do
        let(:sort_dir) { :asc }
        let(:page) { 3 }
        it 'returns empty list' do
          expect(subject).to eq 201
          expect(total_count).to eq 30
          expect(data).to eq []
        end
      end

      context 'when 1st page in descending order is requested' do
        let(:sort_dir) { :desc }
        it 'returns items from 29 to 5' do
          expect(subject).to eq 201
          expect(total_count).to eq 30
          expect(data_ids).to eq asc_order[5..29].reverse
        end
      end
    end
  end

  private

  def assert_manifestation(json, manifestation, view, file_format, snippet)
    md = json['metadata']
    expression = manifestation.expression
    work = expression.work
    expect(md['title']).to eq manifestation.title
    expect(md['sort_title']).to eq manifestation.sort_title
    expect(md['genre']).to eq work.genre
    expect(md['orig_lang']).to eq work.orig_lang
    expect(md['orig_lang_title']).to eq work.origlang_title
    expect(md['pby_publication_date']).to eq work.created_at.to_date.to_s
    expect(md['author_string']).to eq manifestation.author_string
    expect(md['author_ids']).to eq manifestation.author_and_translator_ids
    expect(md['impressions_count']).to eq manifestation.impressions_count
    expect(md['orig_publication_date']).to eq normalize_date(expression.date).to_s
    expect(md['author_genders']).to eq manifestation.author_gender
    expect(md['translator_genders']).to eq manifestation.translator_gender
    expect(md['copyright_status']).to eq manifestation.copyright?
    expect(md['period']).to eq expression.period
    expect(md['raw_creation_date']).to eq work.date
    expect(md['creation_date']).to eq normalize_date(work.date).to_s
    expect(md['publication_place']).to eq manifestation.publication_place
    expect(md['publisher']).to eq manifestation.publisher
    expect(md['raw_publication_date']).to eq expression.date

    if view == 'enriched'
      enrichment = json['enrichment']
      expect(enrichment).to_not be_nil
      json_links = enrichment['external_links']
      links = manifestation.external_links.status_approved.to_a.sort_by(&:id)
      expect(json_links.size).to eq links.size
      links.each_with_index do |el, i|
        json_link = json_links[i]
        expect(json_link['url']).to eq el.url
        expect(json_link['type']).to eq el.linktype
        expect(json_link['description']).to eq el.description
      end

      tags = manifestation.tags.approved.pluck(:name).sort
      expect(enrichment['taggings']).to eq tags

      recommendations = manifestation.recommendations.all_approved.order(:id)
      json_recommendations = enrichment['recommendations']
      recommendations.each_with_index do |r, i|
        json_recommendation = json_recommendations[i]
        expect(json_recommendation['fulltext']).to eq r.body
        expect(json_recommendation['recommender_user_id']).to eq r.user_id
        expect(json_recommendation['recommender_home_url']).to be_nil # Currently it is always nil
        expect(json_recommendation['recommendation_date']).to eq r.created_at.to_date.strftime('%Y-%m-%d')
      end
      works_about = manifestation.expression.work.works_about
      expect(enrichment['texts_about']).to eq works_about.joins(expressions: :manifestations).pluck('manifestations.id').sort
    else
      expect(json.keys).to_not include 'enrichment'
    end

    if snippet
      snippet = json['snippet']
      expect(snippet).to_not be_nil
      # we assume that markdown contains plain-text only
      expect(snippet).to include manifestation.markdown
    else
      expect(json.keys).to_not include 'snippet'
    end

    expect(json['download_url']).to eq Rails.application.routes.url_helpers.manifestation_download_url(manifestation.id, format: file_format)
  end
end