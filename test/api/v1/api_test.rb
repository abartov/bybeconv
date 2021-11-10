require 'test_helper'

class V1::APITest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def setup
    @key = create(:api_key)
    @disabled_key = create(:api_key, status: :disabled)
    @manifestation = create(:manifestation, title: '1st', markdown: 'Sample Text 1')
    @manifestation_2 = create(:manifestation, title: '2nd', markdown: 'Sample Text 2')
    @unpublished_manifestation = create(:manifestation, status: :unpublished)
  end

  def app
    Rails.application
  end

  # -------------------
  # /texts/{id}
  # -------------------

  test 'GET /v1/api/texts/{id} fails if key is not specified' do
    get "/api/v1/texts/#{@manifestation.id}"
    assert last_response.unauthorized?
    assert_equal "key not found or disabled", JSON.parse(last_response.body)["error"]
  end

  test 'GET /v1/api/texts/{id} fails if not-existing key is specified' do
    get "/api/v1/texts/#{@manifestation.id}?key=WRONG_KEY"
    assert last_response.unauthorized?
    assert_equal "key not found or disabled", JSON.parse(last_response.body)["error"]
  end

  test 'GET /v1/api/texts/{id} fails if disabled key is specified' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@disabled_key.key}"
    assert last_response.unauthorized?
    assert_equal "key not found or disabled", JSON.parse(last_response.body)["error"]
  end

  test 'GET /v1/api/texts/{id} with default params succeed and returns basic view in html format' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@key.key}"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_manifestation(json, @manifestation, 'html', true)
  end

  test 'GET /v1/api/texts/{id} with basic view and epub format succeed' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@key.key}&view=basic&file_format=epub"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_manifestation(json, @manifestation, 'epub', true)
  end

  test 'GET /v1/api/texts/{id} with metadata view and pdf format succeed' do
    get "/api/v1/texts/#{@manifestation.id}?key=#{@key.key}&view=metadata&file_format=pdf"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_manifestation(json, @manifestation, 'pdf', false)
  end

  test 'GET /v1/api/texts/{id} fails if id not found in published manifestations' do
    get "/api/v1/texts/#{@unpublished_manifestation.id}?key=#{@key.key}"
    assert last_response.not_found?
    assert_equal "Couldn't find Text with 'id'=#{@unpublished_manifestation.id}", JSON.parse(last_response.body)["error"]
  end

  # -------------------
  # /texts/batch
  # -------------------

  test 'GET /v1/api/texts/batch fails if disabled key is specified' do
    get "/api/v1/texts/batch?key=#{@disabled_key.key}"
    assert last_response.unauthorized?
    assert_equal "key not found or disabled", JSON.parse(last_response.body)["error"]
  end

  test 'GET /v1/api/texts/batch with default params succeed and returns basic view in html format' do
    get "/api/v1/texts/batch?key=#{@key.key}&ids[]=#{@manifestation.id}&ids[]=#{@manifestation_2.id}"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json.size
    assert_manifestation(json[0], @manifestation, 'html', true)
    assert_manifestation(json[1], @manifestation_2, 'html', true)
  end

  test 'GET /v1/api/texts/batch with metadata view and epub format succeed' do
    get "/api/v1/texts/batch?key=#{@key.key}&ids[]=#{@manifestation.id}&ids[]=#{@manifestation_2.id}&view=metadata&file_format=epub"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json.size
    assert_manifestation(json[0], @manifestation, 'epub', false)
    assert_manifestation(json[1], @manifestation_2, 'epub', false)
  end

  test 'GET /v1/api/texts/batch fails if more than 25 ids specified' do
    path = "/api/v1/texts/batch?key=#{@key.key}"
    (1..26).each do |id|
      path << "&ids[]=#{id}"
    end
    get path
    assert last_response.bad_request?
    assert_equal "Couldn't request more that 25 IDs per batch", JSON.parse(last_response.body)["error"]
  end

  test 'GET /v1/api/texts/batch fails if some of ids are not found in published manifestations' do
    get "/api/v1/texts/batch?key=#{@key.key}&ids[]=#{@manifestation.id}&ids[]=#{@unpublished_manifestation.id}"
    assert last_response.not_found?
    assert_equal "Couldn't find one or more Texts with 'id'=#{[@manifestation.id, @unpublished_manifestation.id]}", JSON.parse(last_response.body)["error"]
  end

  # -------------------
  # /texts
  # -------------------

  test 'GET /v1/api/texts fails if disabled key is specified' do
    get "/api/v1/texts?key=#{@disabled_key.key}&page=1"
    assert last_response.unauthorized?
    assert_equal "key not found or disabled", JSON.parse(last_response.body)["error"]
  end

  test 'GET /v1/api/texts fails if page less than 1 is requested' do
    get "/api/v1/texts?key=#{@key.key}&page=0"
    assert last_response.bad_request?
    assert_equal "page must be equal to or above 1", JSON.parse(last_response.body)["error"]
  end

  test 'GET /v1/api/texts returns 1st page with default params' do
    get "/api/v1/texts?key=#{@key.key}&page=1"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json['total_count']
    data = json['data']
    assert_equal 2, data.size
    assert_manifestation(data[0], @manifestation, 'html', true)
    assert_manifestation(data[1], @manifestation_2, 'html', true)
  end

  test 'GET /v1/api/texts returns 1st page with descending alphabetical sorting, metadata view and epub format' do
    get "/api/v1/texts?key=#{@key.key}&page=1&sort_by=alphabetical&sort_dir=desc&view=metadata&file_format=epub"
    assert last_response.successful?
    json = JSON.parse(last_response.body)
    assert_equal 2, json['total_count']
    data = json['data']
    assert_equal 2, data.size
    assert_manifestation(data[0], @manifestation_2, 'epub', false)
    assert_manifestation(data[1], @manifestation, 'epub', false)
  end

  test 'GET /v1/api/texts do correct paging' do
    Manifestation.destroy_all
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

  private

  def assert_manifestation(json, manifestation, format, check_snippet)
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

    if check_snippet
      snippet = json['snippet']
      assert snippet.include? manifestation.title
      # we assume that markdown contains plain-text only
      assert snippet.include? manifestation.markdown
    else
      assert_not json.keys.include?('snippet')
    end

    dl = manifestation.downloadables.where(doctype: format).first
    assert_equal json['download_url'], Rails.application.routes.url_helpers.rails_blob_url(dl.stored_file)
  end
end
