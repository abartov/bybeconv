require 'rails_helper'

describe SearchManifestations do
  REC_COUNT = 200

  before(:all) do
    clean_tables
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

        involved_authorities = []

        # only translated works have translator
        unless lang == 'he'
          involved_authorities << create(:involved_authority, authority: translators[(index  + 7) % translators.length], role: :translator, item: create(:work))
        end

        work = create(
          :work,
          orig_lang: lang,
          genre: genre,
          author: authors[index % authors.length],
          date: created_at.strftime('%d.%m.%Y')
        )
        begin
        expression = create(
          :expression,
          period: period,
          genre: genre,
          involved_authorities: involved_authorities,
          copyrighted: copyrighted,
          date: published_at.strftime('%d.%m.%Y'),
          work: work
        )
        rescue => e
          puts e
        end
        translator = nil
        create(
          :manifestation,
          title: "#{color} #{vegetable} #{index} title",
          impressions_count: index,
          expression: expression,
          created_at: uploaded_at
        )

        uploaded_at += 1.week
        published_at += 1.month
        created_at += 3.months
      end
    end
  end

  after(:all) do
    clean_tables
  end

  describe 'filtering' do
    let!(:subject) { SearchManifestations.call('alphabetical', 'asc', filter) }

    describe 'by genres' do
      let(:filter) { { 'genres' => genres } }

      context 'when single genre specified' do
        let(:genres) { %w(poetry) }
        it 'returns all texts where genre is equal to provided value' do
          expect(subject.count).to eq 40
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.genre).to eq 'poetry'
          end
        end
      end

      context 'when multiple genres specified' do
        let(:genres) { %w(poetry article) }
        it 'returns all texts where genre is included in provided list' do
          expect(subject.count).to eq 80
          subject.limit(REC_COUNT).each do |rec|
            expect(%w(poetry article)).to include rec.genre
          end
        end
      end
    end

    describe 'by periods' do
      let(:filter) { { 'periods' => periods } }

      context 'when single period specified' do
        let(:periods) { %w(ancient) }
        it 'returns all texts where period is equal to provided value' do
          expect(subject.count).to eq 40
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.period).to eq 'ancient'
          end
        end
      end

      context 'when multiple periods specified' do
        let(:periods) { %w(ancient revival) }
        it 'returns all texts where period is included in provided list' do
          expect(subject.count).to eq 80
          subject.limit(REC_COUNT).each do |rec|
            expect(%w(ancient revival)).to include rec.period
          end
        end
      end
    end

    describe 'by copyright' do
      let(:filter)  { { 'is_copyrighted' => is_copyrighted } }

      context 'when copyrighted texts requested' do
        let(:is_copyrighted) { true }
        it 'returns all copyrighted texts' do
          expect(subject.count).to eq 20
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.copyright_status).to be_truthy
          end
        end
      end

      context 'when not copyrighted texts requested' do
        let(:is_copyrighted) { false }
        it 'returns all not copyrighted texts' do
          expect(subject.count).to eq 180
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.copyright_status).to be_falsey
          end
        end
      end
    end

    describe 'by author_genders' do
      let(:filter) { { 'author_genders' => author_genders } }

      context('when single value provided') do
        let(:author_genders) { [:male] }
        it 'returns all records where author has given gender' do
          expect(subject.count).to eq 80
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.author_gender).to eq %w(male)
          end
        end
      end

      context('when multiple values provided') do
        let(:author_genders) { [:male, :female, :unknown] }
        it 'returns all records where author has any of given genders' do
          expect(subject.count).to eq 184
          subject.limit(REC_COUNT).each do |rec|
            expect([%w(male), %w(female), %w(unknown)]).to include rec.author_gender
          end
        end
      end
    end

    describe 'by translator_genders' do
      let(:filter) { { 'translator_genders' => translator_genders } }

      context('when single value provided') do
        let(:translator_genders) { [:female] }
        it 'returns all records where translator has given gender' do
          expect(subject.count).to eq Person.joins(:involved_authorities).where(gender: 'female', involved_authorities: {role: :translator}).count
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.translator_gender).to eq %w(female)
          end
        end
      end

      context('when multiple values provided') do
        let(:translator_genders) { [:male, :female, :other] }
        it 'returns all records where translator has any of given genders' do
          expect(subject.count).to eq Person.joins(:involved_authorities).where(gender: [:male, :female, :other], involved_authorities: {role: :translator}).count
          subject.limit(REC_COUNT).each do |rec|
            expect([%w(male), %w(female), %w(other)]).to include rec.translator_gender
          end
        end
      end
    end

    describe 'by title' do
      let(:filter) { { 'title' => title } }
      context 'when single word is provided' do
        let(:title) { 'lemon' }
        it 'returns all texts including given word in title' do
          expect(subject.count).to eq 50
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.title).to match /lemon/
          end
        end
      end

      context 'when multiple words are provided' do
        let(:title) { 'orange lemon' }
        it 'returns all texts having all this words in same order' do
          expect(subject.count).to eq 10
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.title).to match /orange lemon/
          end
        end
      end

      context 'when multiple words are provided but in a wrong order' do
        # we're using phrase search for title. so order of words is important
        let(:title) { 'lemon orange' }
        it 'finds nothing' do
          expect(subject.count).to eq 0
        end
      end
    end

    describe 'by author' do
      let(:filter) { { 'author' => author } }
      context 'when author name is provided' do
        let(:author) { 'Alpha' }
        it 'returns all texts where author_string includes given name' do
          expect(subject.count).to eq 48
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.author_string).to match /Alpha/
          end
        end
      end

      context 'when translator name is provided' do
        let(:author) { 'Sigma' }
        it 'returns all texts where author_string includes given name' do
          expect(subject.count).to eq 24
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.author_string).to match /Sigma/
          end
        end
      end

      context 'when multiple names are provided' do
        let(:author) { 'Alpha Sigma' }
        it 'returns all texts where author_string includes all of given names' do
          expect(subject.count).to eq 6
          # it takes in account both authors and translators names
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.author_string).to match /Alpha/
            expect(rec.author_string).to match /Sigma/
          end
        end
      end
    end

    describe 'by fulltext' do
      let(:filter) { { 'fulltext' => fulltext } }
      let(:result_ids) { subject.limit(REC_COUNT).map(&:id) }
      let(:manifestation_1) { create(:manifestation, markdown: 'The quick brown fox jumps over the lazy dog') }
      let(:manifestation_2) { create(:manifestation, markdown: 'Dogs are not our whole life, but they make our lives whole.') }
      # Adding word duplication to increase relevance by this word
      let(:manifestation_3) { create(:manifestation, markdown: 'Dogs do speak, but only to those who know how to listen. Dogs! Dogs! Dogs!') }

      before do
        Chewy.strategy(:atomic) do
          manifestation_1
          manifestation_2
          manifestation_3
        end
      end

      context 'when fulltext snippet is provided' do
        let(:fulltext) { 'lazy fox' }
        it 'returns records including those words' do
          expect(result_ids).to eq [ manifestation_1.id ]
        end
      end

      context 'when multiple documents match query' do
        let(:fulltext) { 'but dogs' }
        it 'orders them by relevance' do
          expect(result_ids).to eq [ manifestation_3.id, manifestation_2.id ]
        end
      end

      after do
        Chewy.strategy(:atomic) do
          manifestation_1.destroy
          manifestation_2.destroy
          manifestation_3.destroy
        end
      end
    end

    describe 'by author_ids' do
      let(:filter) { { 'author_ids' => author_ids } }

      context 'when author id is provided' do
        let(:author_id) { Person.find_by(name: 'Beta 1').id }
        let(:author_ids) { [ author_id ] }

        it 'returns all texts written by this author' do
          expect(subject.count).to eq 8
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.author_ids).to include author_id
          end
        end
      end

      context 'when translator id is provided' do
        let(:translator_id) { Person.find_by(name: 'Rho 1').id }
        let(:author_ids) { [ translator_id ] }

        it 'returns all texts translated by this translator' do
          expect(subject.count).to eq 6
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.author_ids).to include translator_id
          end
        end
      end
    end

    describe 'by original_languages' do
      let(:filter) { { 'original_languages' => orig_langs } }

      context 'when single language is provided' do
        let(:orig_langs) { ['ru'] }
        it 'returns all texts written in given language' do
          expect(subject.count).to eq 50
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.orig_lang).to eq 'ru'
          end
        end
      end

      context 'when multiple languages are provided' do
        let(:orig_langs) { %w(ru he) }
        it 'returns all texts written in given languages' do
          expect(subject.count).to eq 100
          subject.limit(REC_COUNT).each do |rec|
            expect(%w(ru he).include?(rec.orig_lang)).to be_truthy
          end
        end
      end

      context 'when magic constant is provided' do
        let(:orig_langs) { ['xlat'] }
        it 'returns all translated texts' do
          expect(subject.count).to eq 150
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.orig_lang).to_not eq 'he'
          end
        end
      end

      context 'when magic constant with specific language is provided' do
        let(:orig_langs) { %w(xlat ru) }
        it 'returns all translated texts' do
          expect(subject.count).to eq 150
          subject.limit(REC_COUNT).each do |rec|
            expect(rec.orig_lang).to_not eq 'he'
          end
        end
      end

      context 'when both magic constant and hebrew are provided' do
        let(:orig_langs) { %w(xlat he) }
        it 'does no filterting and returns all texts' do
          expect(subject.count).to eq 200
        end
      end
    end

    describe 'by upload date' do
      let(:filter) { { 'uploaded_between' => range } }
      let(:index_attr) { :pby_publication_date }

      context "when 'from' and 'to' values are equal" do
        let(:range) { { 'from' => 2010, 'to' => 2010 } }
        it 'returns all records uploaded in given year' do
          assert_date_range(53)
        end
      end

      context "when 'from' and 'to' values are different" do
        let(:range) { { 'from' => 2010, 'to' => 2011 } }
        it "returns all records uploaded from beginning of 'from' to end of 'to' year" do
          assert_date_range(105)
        end
      end

      context "when only 'from' value provided" do
        let(:range) { { 'from' => 2012 } }
        it 'returns all records uploaded starting from given year' do
          assert_date_range(95)
        end
      end

      context "when only 'to' value provided" do
        let(:range) { { 'to' => 2010 } }
        it 'returns all records uploaded before given year' do
          assert_date_range(53)
        end
      end
    end

    describe 'by publication date' do
      let(:filter) { { 'published_between' => range } }
      let(:index_attr) { :orig_publication_date }

      context "when 'from' and 'to' values are equal" do
        let(:range) { { 'from' => 1980, 'to' => 1980 } }
        it 'returns all records published in given year' do
          assert_date_range(12)
        end
      end

      context "when 'from' and 'to' values are different" do
        let(:range) { { 'from' => 1990, 'to' => 1992 } }
        it "returns all records published from beginning of 'from' to end of 'to' year" do
          assert_date_range(36)
        end
      end

      context "when only 'from' value provided" do
        let(:range) { { 'from' => 1985 } }
        it 'returns all records published starting from given year' do
          assert_date_range(140)
        end
      end

      context "when only 'to' value provided" do
        let(:range) { { 'to' => 1984 } }
        it 'returns all records published before or in given year' do
          assert_date_range(60)
        end
      end
    end

    describe 'by creation date' do
      let(:filter) { { 'created_between' => range } }
      let(:index_attr) { :creation_date }

      context "when 'from' and 'to' values are equal" do
        let(:range) { { 'from' => 1950, 'to' => 1950 } }
        it 'returns all records created in given year' do
          assert_date_range(4)
        end
      end

      context "when 'from' and 'to' values are different" do
        let(:range) { { 'from' => 1950, 'to' => 1952 } }
        it "returns all records created from beginning of 'from' to end of 'to' year" do
          assert_date_range(12)
        end
      end

      context "when only 'from' value provided" do
        let(:range) { { 'from' => 1985 } }
        it 'returns all records created starting from given year' do
          assert_date_range(60)
        end
      end

      context "when only 'to' value provided" do
        let(:range) { { 'to' => 1952 } }
        it 'returns all records created before or in given year' do
          assert_date_range(12)
        end
      end
    end
  end

  describe 'sorting' do
    let!(:subject) do
      SearchManifestations.call(sorting, sort_dir, {}).limit(REC_COUNT).map(&:id)
    end
    let(:asc_order) { Manifestation.all_published.order(db_column => :asc).pluck(:id) }
    let(:desc_order) { asc_order.reverse }

    describe 'alphabetical' do
      let(:db_column) { :sort_title }
      let(:sorting) { 'alphabetical' }
      context 'when default sort direction is requested' do
        let(:sort_dir) { 'default'}
        it { is_expected.to eq asc_order }
      end
      context 'when asc sort direction is requested' do
        let(:sort_dir) { 'asc'}
        it { is_expected.to eq asc_order }
      end
      context 'when desc sort direction is requested' do
        let(:sort_dir) { 'desc'}
        it { is_expected.to eq desc_order }
      end
    end

    describe 'popularity' do
      let(:db_column) { :impressions_count }
      let(:sorting) { 'popularity' }
      context 'when default sort direction is requested' do
        let(:sort_dir) { 'default'}
        it { is_expected.to eq desc_order }
      end
      context 'when asc sort direction is requested' do
        let(:sort_dir) { 'asc'}
        it { is_expected.to eq asc_order }
      end
      context 'when desc sort direction is requested' do
        let(:sort_dir) { 'desc'}
        it { is_expected.to eq desc_order }
      end
    end

    describe 'publication_date' do
      let(:asc_order) do
        Manifestation.all_published.joins(:expression).order('expressions.normalized_pub_date').pluck(:id)
      end
      let(:sorting) { 'publication_date' }
      context 'when default sort direction is requested' do
        let(:sort_dir) { 'default'}
        it { is_expected.to eq asc_order }
      end
      context 'when asc sort direction is requested' do
        let(:sort_dir) { 'asc'}
        it { is_expected.to eq asc_order }
      end
      context 'when desc sort direction is requested' do
        let(:sort_dir) { 'desc'}
        it { is_expected.to eq desc_order }
      end
    end

    describe 'creation_date' do
      let(:asc_order) do
        Manifestation.all_published.joins(expression: :work).order('works.normalized_creation_date').pluck(:id)
      end
      let(:sorting) { 'creation_date' }
      context 'when default sort direction is requested' do
        let(:sort_dir) { 'default'}
        it { is_expected.to eq asc_order }
      end
      context 'when asc sort direction is requested' do
        let(:sort_dir) { 'asc'}
        it { is_expected.to eq asc_order }
      end
      context 'when desc sort direction is requested' do
        let(:sort_dir) { 'desc'}
        it { is_expected.to eq desc_order }
      end
    end

    describe 'upload_date' do
      let(:db_column) { :created_at }
      let(:sorting) { 'upload_date' }
      context 'when default sort direction is requested' do
        let(:sort_dir) { 'default'}
        it { is_expected.to eq desc_order }
      end
      context 'when asc sort direction is requested' do
        let(:sort_dir) { 'asc'}
        it { is_expected.to eq asc_order }
      end
      context 'when desc sort direction is requested' do
        let(:sort_dir) { 'desc'}
        it { is_expected.to eq desc_order }
      end
    end
  end

  private

  def assert_date_range(expected_count)
    expect(subject.count).to eq expected_count
    from = Time.parse("#{range['from']}-01-01") if range['from'].present?
    to = Time.parse("#{range['to']}-12-31 23:59:59") if range['to'].present?
    subject.limit(REC_COUNT).each do |rec|
      time = Time.parse(rec.send(index_attr))
      if from.present?
        expect(time).to be >= from
      end
      if to.present?
        expect(time).to be <= to
      end
    end
  end
end
