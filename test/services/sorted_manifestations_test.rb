require 'test_helper'

class SortedManifestationsTest < ActiveSupport::TestCase
  def setup
    create(
      :manifestation,
      created_at: Time.parse('2011-03-01'),
      title: "1st",
      impressions_count: 200,
      expressions: [
        create(:expression, date: '01.01.2011', works: [ create(:work, date: '01.02.2011') ])
      ]
    )
    create(
      :manifestation,
      created_at: Time.parse('2012-03-01'),
      title: "2nd",
      impressions_count: 50,
      expressions: [
        create(:expression, date: '01.01.2012', works: [ create(:work, date: '01.02.2012') ])
      ]
    )
    create(
      :manifestation,
      created_at: Time.parse('2013-03-01'),
      title: "3rd",
      impressions_count: 100,
      expressions: [
        create(:expression, date: '01.01.2013', works: [ create(:work, date: '01.02.2013') ])
      ]
    )
  end

  test "Alphabetical sorting" do
    assert_equal %w(1st 2nd 3rd), SortedManifestations.call('alphabetical', 'default').map(&:sort_title)
    assert_equal %w(1st 2nd 3rd), SortedManifestations.call('alphabetical', 'asc').map(&:sort_title)
    assert_equal %w(3rd 2nd 1st), SortedManifestations.call('alphabetical', 'desc').map(&:sort_title)
  end

  test "Popularity sorting" do
    assert_equal [200, 100, 50], SortedManifestations.call('popularity', 'default').map(&:impressions_count)
    assert_equal [50, 100, 200], SortedManifestations.call('popularity', 'asc').map(&:impressions_count)
    assert_equal [200, 100, 50], SortedManifestations.call('popularity', 'desc').map(&:impressions_count)
  end

  test "Publication date sorting" do
    assert_equal %w(2011-01-01 2012-01-01 2013-01-01), SortedManifestations.call('publication_date', 'default').map { |m| m.expressions[0].normalized_pub_date }
    assert_equal %w(2011-01-01 2012-01-01 2013-01-01), SortedManifestations.call('publication_date', 'asc').map { |m| m.expressions[0].normalized_pub_date }
    assert_equal %w(2013-01-01 2012-01-01 2011-01-01), SortedManifestations.call('publication_date', 'desc').map { |m| m.expressions[0].normalized_pub_date }
  end

  test 'Creation date sorting' do
    assert_equal %w(2011-02-01 2012-02-01 2013-02-01), SortedManifestations.call('creation_date', 'default').map { |m| m.expressions[0].works[0].normalized_creation_date }
    assert_equal %w(2011-02-01 2012-02-01 2013-02-01), SortedManifestations.call('creation_date', 'asc').map { |m| m.expressions[0].works[0].normalized_creation_date }
    assert_equal %w(2013-02-01 2012-02-01 2011-02-01), SortedManifestations.call('creation_date', 'desc').map { |m| m.expressions[0].works[0].normalized_creation_date }
  end

  test 'Upload date sorting' do
    assert_equal [Time.parse('2013-03-01'), Time.parse('2012-03-01'), Time.parse('2011-03-01')], SortedManifestations.call('upload_date', 'default').map { |m| m.created_at }
    assert_equal [Time.parse('2011-03-01'), Time.parse('2012-03-01'), Time.parse('2013-03-01')], SortedManifestations.call('upload_date', 'asc').map { |m| m.created_at }
    assert_equal [Time.parse('2013-03-01'), Time.parse('2012-03-01'), Time.parse('2011-03-01')], SortedManifestations.call('upload_date', 'desc').map { |m| m.created_at }
  end
end
