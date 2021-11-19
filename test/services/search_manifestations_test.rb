require 'test_helper'

class SearchManifestationsTest < ActiveSupport::TestCase
  REC_COUNT = 200

  def setup
    Chewy.massacre
    Chewy.strategy(:atomic) do

      authors = []
      translators = []

      # We create 25 authors and 25 translators
      (1..25).each do |index|
        author_name = %w(Alpha Beta Gamma Delta)[index % 4]
        translator_name = %w(Pi Rho Sigma Tau Upsilon Phi)[index % 6]
        gender = if index % 10 == 0
                   'other'
                 elsif index % 5  == 0
                   'unknown'
                 else
                   index % 2 == 0 ? 'male' : 'female'
                 end
        authors << create(:person, name: "#{author_name} #{index}", gender: gender)
        translators << create(:person, name: "#{translator_name} #{index}", gender: gender)
      end

      uploaded_at = Time.parse('2010-01-01 12:00:00')
      published_at = Time.parse('1980-01-01')
      created_at = Time.parse('1950-01-01')

      (1..REC_COUNT).each do |index|
        # generating random titles containing similar words
        color = %w(red orange yellow green blue)[index % 5]
        vegetable = %w(tomato lemon cucumber melon)[index % 4]

        lang = %w(ru en de he)[index % 4]

        genre = %w(poetry prose drama fables article)[index % 5]
        period = %w(ancient medieval enlightenment revival modern)[index % 5]
        copyrighted = index % 10 == 0

        creations = [ create(:creation, person: authors[index % authors.length], role: :author) ]
        realizers = []

        # only translated works have translator
        unless lang == 'he'
          realizers << create(:realizer, person: translators[(index  + 7) % translators.length], role: :translator)
        end

        work = create(
          :work,
          orig_lang: lang,
          genre: genre,
          creations: creations,
          date: created_at.strftime('%d.%m.%Y')
        )
        expression = create(
          :expression,
          period: period,
          copyrighted: copyrighted,
          realizers: realizers,
          date: published_at.strftime('%d.%m.%Y'),
          works: [work]
        )
        create(
          :manifestation,
          title: "#{color} #{vegetable} #{index} title",
          impressions_count: index,
          expressions: [expression],created_at: uploaded_at
        )

        uploaded_at += 1.week
        published_at += 1.month
        created_at += 3.months
      end
    end
  end

  test 'Filter by genres works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'genres' => %w(poetry) })
    assert_equal 40, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_equal 'poetry', rec.genre
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'genres' => %w(poetry article) })
    assert_equal 80, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes %w(poetry article), rec.genre
    end
  end

  test 'Filter by periods works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'periods' => %w(ancient) })
    assert_equal 40, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_equal 'ancient', rec.period
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'periods' => %w(ancient revival) })
    assert_equal 80, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes %w(ancient revival), rec.period
    end
  end

  test 'Filter by copyright works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'is_copyrighted' => true })
    assert_equal 20, records.count
    records.limit(REC_COUNT).each do |rec|
      assert rec.copyright_status
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'is_copyrighted' => false })
    assert_equal 180, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_not rec.copyright_status
    end
  end

  test 'Filter by author_genders works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'author_genders' => [:male] })
    assert_equal 80, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_equal %w(male), rec.author_gender
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'author_genders' => [:male, :female, :unknown] })
    assert_equal 184, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes [%w(male), %w(female), %w(unknown)], rec.author_gender
    end
  end

  test 'Filter by translator_genders works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'translator_genders' => [:female] })
    assert_equal 60, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_equal %w(female), rec.translator_gender
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'translator_genders' => [:male, :female, :other] })
    assert_equal 132, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes [%w(male), %w(female), %w(other)], rec.translator_gender
    end
  end

  test 'Filter by title works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'title' => 'orange' })
    assert_equal 40, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_match /orange/, rec.title
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'title' => 'orange lemon' })
    assert_equal 10, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_match /orange lemon/, rec.title
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'title' => 'Abrakadabra' })
    assert_equal 0, records.count
  end

  test 'Filter by author works' do
    # Searches by author's name
    records = SearchManifestations.call('alphabetical', 'asc', { 'author' => 'Alpha' })
    assert_equal 48, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_match /Alpha/, rec.author_string
    end

    # it also searches by translator's name
    records = SearchManifestations.call('alphabetical', 'asc', { 'author' => 'Sigma' })
    assert_equal 24, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_match /Sigma/, rec.author_string
    end

    # mixed search by author and translator names, returns records where any of provided words matches author
    # or translator (or both)
    records = SearchManifestations.call('alphabetical', 'asc', { 'author' => 'Sigma Alpha' })
    assert_equal 66, records.count
    records.limit(REC_COUNT).each do |rec|
      assert rec.author_string =~ /(Sigma|Alpha)/
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'author' => 'Abrakadabra' })
    assert_equal 0, records.count
  end

  test 'Search by both author and title works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'author' => 'Alpha', 'title' => 'orange lemon' })
    assert_equal 2, records.count

    records.limit(REC_COUNT).each do |rec|
      assert_match /Alpha/, rec.author_string
      assert_match /orange lemon/, rec.title
    end
  end

  test 'Filter by author_ids works' do
    author_id = Person.find_by(name: 'Beta 1').id
    records = SearchManifestations.call('alphabetical', 'asc', { 'author_ids' => [author_id] })
    assert_equal 8, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes rec.author_ids, author_id
    end

    # it also takes in account translators
    translator_id = Person.find_by(name: 'Rho 1').id
    records = SearchManifestations.call('alphabetical', 'asc', { 'author_ids' => [translator_id] })
    assert_equal 6, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes rec.author_ids, translator_id
    end
  end

  test 'Filter by original_language works' do
    # search by a single language
    records = SearchManifestations.call('alphabetical', 'asc', { 'original_language' => 'ru' })
    assert_equal 50, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_equal 'ru', rec.orig_lang
    end

    # xlat means 'all translated', so we should get all works except works in Hebrew
    records = SearchManifestations.call('alphabetical', 'asc', { 'original_language' => 'xlat' })
    assert_equal 150, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes %w(ru en de), rec.orig_lang
    end
  end

  test 'Filter by uploaded date works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'uploaded_between' => [2010, 2010] })
    assert_equal 53, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes Time.parse('2010-01-01')..Time.parse('2010-12-31 23:59:59'), Time.parse(rec.pby_publication_date)
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'uploaded_between' => [2010, 2011] })
    assert_equal 105, records.count

    records = SearchManifestations.call('alphabetical', 'asc', { 'uploaded_between' => [nil, 2010] })
    assert_equal 53, records.count

    records = SearchManifestations.call('alphabetical', 'asc', { 'uploaded_between' => [2012, nil] })
    assert_equal 95, records.count

    # if no limits specified, it returns all records
    records = SearchManifestations.call('alphabetical', 'asc', { 'uploaded_between' => [nil, nil] })
    assert_equal REC_COUNT, records.count
  end

  test 'Filter by publication date works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'published_between' => [1980, 1980] })
    assert_equal 12, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes Time.parse('1980-01-01')..Time.parse('1980-12-31 23:59:59'), Time.parse(rec.orig_publication_date)
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'published_between' => [1990, 1992] })
    assert_equal 36, records.count

    records = SearchManifestations.call('alphabetical', 'asc', { 'published_between' => [nil, 1984] })
    assert_equal 60, records.count

    records = SearchManifestations.call('alphabetical', 'asc', { 'published_between' => [1985, nil] })
    assert_equal 140, records.count
  end

  test 'Filter by creation date works' do
    records = SearchManifestations.call('alphabetical', 'asc', { 'created_between' => [1950, 1950] })
    assert_equal 4, records.count
    records.limit(REC_COUNT).each do |rec|
      assert_includes Time.parse('1950-01-01')..Time.parse('1950-12-31 23:59:59'), Time.parse(rec.creation_date)
    end

    records = SearchManifestations.call('alphabetical', 'asc', { 'created_between' => [1950, 1952] })
    assert_equal 12, records.count

    records = SearchManifestations.call('alphabetical', 'asc', { 'created_between' => [nil, 1952] })
    assert_equal 12, records.count

    records = SearchManifestations.call('alphabetical', 'asc', { 'created_between' => [1985, nil] })
    assert_equal 60, records.count
  end

  test 'Alphabetical sorting works' do
    asc_order = Manifestation.all_published.order(title: :asc).map(&:id)

    records = SearchManifestations.call('alphabetical', 'default', { })
    assert_equal asc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('alphabetical', 'asc', { })
    assert_equal asc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('alphabetical', 'desc', { })
    assert_equal asc_order.reverse, records.limit(REC_COUNT).map(&:id)
  end

  test 'Popularity sorting works' do
    desc_order = Manifestation.all_published.order(impressions_count: :desc).map(&:id)

    records = SearchManifestations.call('popularity', 'default', { })
    assert_equal desc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('popularity', 'asc', { })
    assert_equal desc_order.reverse, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('popularity', 'desc', { })
    assert_equal desc_order, records.limit(REC_COUNT).map(&:id)
  end

  test 'Publication date sorting works' do
    asc_order = Manifestation.all_published.joins(:expressions).order('expressions.normalized_pub_date').map(&:id)

    records = SearchManifestations.call('publication_date', 'default', { })
    assert_equal asc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('publication_date', 'asc', { })
    assert_equal asc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('publication_date', 'desc', { })
    assert_equal asc_order.reverse, records.limit(REC_COUNT).map(&:id)
  end

  test 'Creation date sorting works' do
    asc_order = Manifestation.all_published.joins(expressions: :works).order('works.normalized_creation_date').map(&:id)

    records = SearchManifestations.call('creation_date', 'default', { })
    assert_equal asc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('creation_date', 'asc', { })
    assert_equal asc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('creation_date', 'desc', { })
    assert_equal asc_order.reverse, records.limit(REC_COUNT).map(&:id)
  end

  test 'Upload date sorting works' do
    desc_order = Manifestation.all_published.order(created_at: :desc).map(&:id)

    records = SearchManifestations.call('upload_date', 'default', { })
    assert_equal desc_order, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('upload_date', 'asc', { })
    assert_equal desc_order.reverse, records.limit(REC_COUNT).map(&:id)

    records = SearchManifestations.call('upload_date', 'desc', { })
    assert_equal desc_order, records.limit(REC_COUNT).map(&:id)
  end


end
