require 'test_helper'

class V1::APITest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def setup
    @key = create(:api_key)
    @manifestation = create(:manifestation, markdown: 'Sample Text')
  end

  def app
    Rails.application
  end

  test 'GET /v1/api/texts/{id} fails if disabled key is specified' do
    key = create(:api_key, status: :disabled)
    get "/api/v1/texts/#{@manifestation.id}?key=#{key.key}"
    assert last_response.bad_request?
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

  private

  def assert_manifestation(json, manifestation, format, check_snippet)
    json = JSON.parse(last_response.body)
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
      assert snippet.include? 'Sample Text'
    else
      assert_not json.keys.include?('snippet')
    end

    dl = manifestation.downloadables.where(doctype: format).first
    assert_equal json['download_url'], Rails.application.routes.url_helpers.rails_blob_url(dl.stored_file)
  end
end
