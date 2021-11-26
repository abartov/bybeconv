require 'test_helper'

class V1::APITest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def setup
    @key = create(:api_key)
    @disabled_key = create(:api_key, status: :disabled)

    tag_popular = create(:tag, name: :popular)
    tag_unpopular = create(:tag, name: :unpopular)
    tag_pending = create(:tag, name: :pending, status: :pending)

    Chewy.strategy(:atomic) do
      @manifestation = create(
        :manifestation, :with_recommendations, :with_external_links,
        title: '1st',
        impressions_count: 3,
        markdown: 'Sample Text 1',
        taggings: [ create(:tagging, tag: tag_popular),  create(:tagging, tag: tag_pending) ]
      )
      @manifestation_2 = create(
        :manifestation, :with_recommendations, :with_external_links,
        title: '2nd',
        impressions_count: 2,
        markdown: 'Sample Text 2',
        taggings: [ create(:tagging, tag: tag_unpopular), create(:tagging, tag: tag_pending) ]
      )

      create(:aboutness, work: @manifestation_2.expressions[0].works[0], aboutable: @manifestation.expressions[0].works[0])

      @unpublished_manifestation = create(:manifestation, status: :unpublished)
    end
  end

  def app
    Rails.application
  end

  # -------------------
  # /texts/{id}
  # -------------------

  test 'GET /v1/api/texts/{id} fails if key is not specified' do
    get "/api/v1/texts/#{@manifestation.id}"
    assert_key_failed
  end

  test 'GET /v1/api/texts/{id} fails if not-existing key is specified' do
    get "/api/v1/texts/#{@manifestation.id}?key=WRONG_KEY"
    assert_key_failed
  end

  test 'GET /v1/api/texts/{id} fails if disabled key is specified' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@disabled_key.key}"
    assert_key_failed
  end

  test 'GET /v1/api/texts/{id} with default params succeed and returns basic view in html format without snippet' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@key.key}"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_manifestation(json, @manifestation, 'basic', 'html', false)
  end

  test 'GET /v1/api/texts/{id} with basic view, epub format and snippet succeed' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@key.key}&view=basic&file_format=epub&snippet=true"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_manifestation(json, @manifestation, 'basic', 'epub', true)
  end

  test 'GET /v1/api/texts/{id} with metadata view, pdf format and without snippet succeed' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@key.key}&view=metadata&file_format=pdf&snippet=false"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_manifestation(json, @manifestation, 'metadata', 'pdf', false)
  end

  test 'GET /v1/api/texts/{id} with enriched view, pdf format and without snippet succeed' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@key.key}&view=enriched&file_format=pdf&snippet=false"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_manifestation(json, @manifestation, 'enriched', 'pdf', false)
    # ensuring non-published tags are excluded
    assert_equal %w(popular), json['enrichment']['taggings']
    # checking works_about
    assert_equal [@manifestation_2.id], json['enrichment']['works_about']
  end

  test 'GET /v1/api/texts/{id} fails if id not found in published manifestations' do
    get "/api/v1/texts/#{@unpublished_manifestation.id}?key=#{@key.key}"
    assert last_response.not_found?
    assert_equal "Couldn't find Text with 'id'=#{@unpublished_manifestation.id}", last_error
  end

  # -------------------
  # /texts/batch
  # -------------------

  test 'GET /v1/api/texts/batch fails if disabled key is specified' do
    get "/api/v1/texts/batch?key=#{@disabled_key.key}"
    assert last_response.unauthorized?
    assert_key_failed
  end

  test 'GET /v1/api/texts/batch with default params succeed and returns basic view in html format and without snippet' do
    get "/api/v1/texts/batch?key=#{@key.key}&ids[]=#{@manifestation.id}&ids[]=#{@manifestation_2.id}"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json.size
    assert_manifestation(json[0], @manifestation, 'basic', 'html', false)
    assert_manifestation(json[1], @manifestation_2, 'basic', 'html', false)
  end

  test 'GET /v1/api/texts/batch with enriched view, epub format and snippet succeed' do
    get "/api/v1/texts/batch?key=#{@key.key}&ids[]=#{@manifestation.id}&ids[]=#{@manifestation_2.id}&view=enriched&file_format=epub&snippet=true"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json.size
    assert_manifestation(json[0], @manifestation, 'enriched', 'epub', true)
    assert_manifestation(json[1], @manifestation_2, 'enriched', 'epub', true)
  end

  test 'GET /v1/api/texts/batch fails if more than 25 ids specified' do
    path = "/api/v1/texts/batch?key=#{@key.key}"
    (1..26).each do |id|
      path << "&ids[]=#{id}"
    end
    get path
    assert last_response.bad_request?
    assert_equal "ids must have up to 25 items", last_error
  end

  test 'GET /v1/api/texts/batch fails if some of ids are not found in published manifestations' do
    get "/api/v1/texts/batch?key=#{@key.key}&ids[]=#{@manifestation.id}&ids[]=#{@unpublished_manifestation.id}"
    assert last_response.not_found?
    assert_equal "Couldn't find one or more Texts with 'id'=#{[@manifestation.id, @unpublished_manifestation.id]}", last_error
  end

  # -------------------
  # /texts
  # -------------------

  test 'GET /v1/api/texts fails if disabled key is specified' do
    get "/api/v1/texts?key=#{@disabled_key.key}&page=1"
    assert_key_failed
  end

  test 'GET /v1/api/texts fails if page less than 1 is requested' do
    get "/api/v1/texts?key=#{@key.key}&page=0"
    assert last_response.bad_request?
    assert_equal "page must be equal to or above 1", last_error
  end

  test 'GET /v1/api/texts returns 1st page with default params' do
    get "/api/v1/texts?key=#{@key.key}&page=1"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json['total_count']
    data = json['data']
    assert_equal 2, data.size
    assert_manifestation(data[0], @manifestation, 'basic', 'html', false)
    assert_manifestation(data[1], @manifestation_2, 'basic', 'html', false)
  end

  test 'GET /v1/api/texts returns 1st page with descending alphabetical sorting, metadata view, epub format and snippet' do
    get "/api/v1/texts?key=#{@key.key}&page=1&sort_by=alphabetical&sort_dir=desc&view=metadata&file_format=epub&snippet=true"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json['total_count']
    data = json['data']
    assert_equal 2, data.size
    assert_manifestation(data[0], @manifestation_2, 'metadata', 'epub', true)
    assert_manifestation(data[1], @manifestation, 'metadata', 'epub', true)
  end

  test 'GET /v1/api/texts do correct paging' do
    clean_tablees
    manifestations = create_list(:manifestation, 60)
    get "/api/v1/texts?key=#{@key.key}&page=1&sort_by=upload_date&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    data = json['data']
    assert_equal 25, data.size
    assert_equal manifestations[0..24].map(&:id), data.map { |rec| rec['id'] }

    get "/api/v1/texts?key=#{@key.key}&page=2&sort_by=upload_date&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    data = json['data']
    assert_equal 25, data.size
    assert_equal manifestations[25..49].map(&:id), data.map { |rec| rec['id'] }

    get "/api/v1/texts?key=#{@key.key}&page=3&sort_by=upload_date&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    data = json['data']
    assert_equal 10, data.size
    assert_equal manifestations[50..60].map(&:id), data.map { |rec| rec['id'] }

    get "/api/v1/texts?key=#{@key.key}&page=4&sort_by=upload_date&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    assert_empty json['data']
  end

  # -------------------
  # /search
  # -------------------

  test 'GET /v1/api/search fails if disabled key is specified' do
    get "/api/v1/search?key=#{@disabled_key.key}&page=1"
    assert_key_failed
  end

  test 'GET /v1/api/search returns 1st page with default params' do
    get "/api/v1/search?key=#{@key.key}&page=1"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json['total_count']
    data = json['data']
    assert_equal 2, data.size
    assert_manifestation(data[0], @manifestation, 'basic', 'html', false)
    assert_manifestation(data[1], @manifestation_2, 'basic', 'html', false)
  end

  test 'GET /v1/api/search returns 1st page with descending popularity sorting, enriched view, epub format and snippet' do
    get "/api/v1/search?key=#{@key.key}&page=1&sort_by=popularity&sort_dir=asc&view=enriched&file_format=epub&snippet=true"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json['total_count']
    data = json['data']
    assert_equal 2, data.size
    assert_manifestation(data[0], @manifestation_2, 'enriched', 'epub', true)
    assert_manifestation(data[1], @manifestation, 'enriched', 'epub', true)
  end

  test 'GET /v1/api/search applies filters' do
    manifestations = []
    Chewy.strategy(:atomic) do
      clean_tablees
      (1..60).each do |index|
        e = create(:expression, copyrighted: index%10 == 0)
        manifestations << create(:manifestation, impressions_count: Random.rand(100), expressions: [e])
      end
    end

    get "/api/v1/search?key=#{@key.key}&page=1&sort_by=popularity&sort_dir=asc&is_copyrighted=true"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 6, json['total_count']
    data = json['data']
    assert_equal 6, data.size
    expected_ids = manifestations.select(&:copyright?).sort_by(&:impressions_count).map(&:id)
    assert_equal expected_ids, data.map { |rec| rec['id'] }
  end

  test 'GET /v1/api/search passes all filter params to SearchManifestation service' do
    filter = "genres[]=poetry&periods[]=revival&is_copyrighted=true&author_genders[]=male&translator_genders[]=female"
    filter << "&title=Title&author=Author&author_ids[]=1&author_ids[]=2&original_language=ru"
    filter << "&uploaded_between[]=&uploaded_between[]=2016"
    filter << "&created_between[]=1981&created_between[]=1986"
    filter << "&published_between[]=1990&published_between[]="

    # We simply check if all params are passed to SearchManifestation correctly.
    # SearchManifestation has own test
    expected_hash = {
      'genres' => %w(poetry),
      'periods' => %w(revival),
      'is_copyrighted' => true,
      'author_genders' => %w(male),
      'translator_genders' => %w(female),
      'title' => 'Title',
      'author' => 'Author',
      'author_ids' => [1, 2],
      'original_language' => 'ru',
      'uploaded_between' => [nil, 2016],
      'created_between' => [1981, 1986],
      'published_between' => [1990, nil]
    }

    records = mock()
    records.expects(:offset).with(25).returns(records)
    records.expects(:limit).with(25).returns(records)
    records.expects(:to_a).returns([])
    records.expects(:count).returns(5)

    SearchManifestations.any_instance.expects(:call).with('popularity', 'asc', expected_hash).returns(records)

    get "/api/v1/search?key=#{@key.key}&view=metadata&file_format=pdf&page=2&sort_by=popularity&sort_dir=asc&#{filter}"

    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 5, json['total_count']
    data = json['data']
    assert_equal 0, data.size
  end

  test 'GET /v1/api/search do correct paging' do
    manifestations = []
    Chewy.strategy(:atomic) do
      clean_tablees
      (1..60).each do |index|
        manifestations << create(:manifestation, impressions_count: Random.rand(100))
      end
    end

    asc_ids = manifestations.sort_by(&:impressions_count).map(&:id)

    get "/api/v1/search?key=#{@key.key}&page=1&sort_by=popularity&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    data = json['data']
    assert_equal 25, data.size
    assert_equal asc_ids[0..24], data.map { |rec| rec['id'] }

    get "/api/v1/search?key=#{@key.key}&page=2&sort_by=popularity&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    data = json['data']
    assert_equal 25, data.size
    assert_equal asc_ids[25..49], data.map { |rec| rec['id'] }

    get "/api/v1/search?key=#{@key.key}&page=2&sort_by=popularity&sort_dir=desc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    data = json['data']
    assert_equal 25, data.size
    assert_equal asc_ids.reverse[25..49], data.map { |rec| rec['id'] }

    get "/api/v1/search?key=#{@key.key}&page=3&sort_by=popularity&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    data = json['data']
    assert_equal 10, data.size
    assert_equal asc_ids[50..60], data.map { |rec| rec['id'] }

    get "/api/v1/search?key=#{@key.key}&page=4&sort_by=popularity&sort_dir=asc"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 60, json['total_count']
    assert_empty json['data']
  end

  private

  def assert_manifestation(json, manifestation, view, file_format, snippet)
    md = json['metadata']
    expression = manifestation.expressions[0]
    work = expression.works[0]
    assert_equal manifestation.title, md['title']
    assert_equal manifestation.sort_title, md['sort_title']
    assert_equal work.genre, md['genre']
    assert_equal work.orig_lang, md['orig_lang']
    assert_equal work.origlang_title, md['orig_lang_title']
    assert_equal work.created_at.to_date.to_s, md['pby_publication_date']
    assert_equal manifestation.author_string, md['author_string']
    assert_equal manifestation.author_and_translator_ids, md['author_ids']
    assert_equal manifestation.title_and_authors, md['title_and_authors']
    assert_equal manifestation.impressions_count, md['impressions_count']
    assert_equal normalize_date(expression.date).to_s, md['orig_publication_date']
    assert_equal manifestation.author_gender, md['author_gender']
    assert_equal manifestation.translator_gender, md['translator_gender']
    assert_equal manifestation.copyright?, md['copyright_status']
    assert_equal expression.period, md['period']
    assert_equal work.date, md['raw_creation_date']
    assert_equal normalize_date(work.date).to_s, md['creation_date']
    assert_equal "#{manifestation.publication_place}, #{manifestation.publisher}", md['place_and_publisher']
    assert_equal expression.date, md['raw_publication_date']
    assert_equal normalize_date(expression.date).year, md['publication_year']

    if view == 'enriched'
      enrichment = json['enrichment']
      assert_not_nil enrichment
      json_links = enrichment['external_links']
      links = manifestation.external_links.status_approved.to_a.sort_by(&:id)
      assert_equal links.size, json_links.size
      links.each_with_index do |el, i|
        json_link = json_links[i]
        assert_equal el.url, json_link['url']
        assert_equal el.linktype, json_link['type']
        assert_equal el.description, json_link['description']
      end

      tags = manifestation.tags.approved.pluck(:name).sort
      assert_equal tags, enrichment['taggings']

      recommendations = manifestation.recommendations.all_approved.order(:id)
      json_recommendations = enrichment['recommendations']
      recommendations.each_with_index do |r, i|
        json_recommendation = json_recommendations[i]
        assert_equal r.body, json_recommendation['fulltext']
        assert_equal r.user_id, json_recommendation['recommender_user_id']
        assert_nil json_recommendation['recommender_home_url']
        assert_equal r.created_at.to_date.strftime('%Y-%m-%d'), json_recommendation['recommendation_date']
      end
      works_about = manifestation.expressions[0].works[0].works_about
      assert_equal works_about.joins(expressions: :manifestations).pluck('manifestations.id').sort, enrichment['works_about']
    else
      assert_not json.keys.include?('enrichment')
    end

    if snippet
      snippet = json['snippet']
      assert_not_nil snippet
      assert snippet.include? manifestation.title
      # we assume that markdown contains plain-text only
      assert snippet.include? manifestation.markdown
    else
      assert_not json.keys.include?('snippet')
    end

    assert_equal json['download_url'], Rails.application.routes.url_helpers.manifestation_download_url(manifestation.id, format: file_format)
  end

  def last_error
    return JSON.parse(last_response.body)["error"]
  end

  def assert_key_failed
    assert_equal "key not found or disabled", last_error
  end

  def clean_tablees
    Tagging.destroy_all
    ExternalLink.destroy_all
    Recommendation.destroy_all
    Manifestation.destroy_all
  end
end
