class ManifestationsIndex < Chewy::Index

  # works
  define_type Manifestation.all_published.includes(expressions: :works) do
#    field :title, analyzer: 'hebrew' # from https://github.com/synhershko/elasticsearch-analysis-hebrew
#    field :fulltext, value: ->(manifestation) {manifestation.to_plaintext}, analyzer: 'hebrew'
    field :id, type: 'integer'
    field :title
    field :sort_title, type: 'keyword' # for sorting
    field :first_letter, value: ->(manifestation) {manifestation.first_hebrew_letter}
    field :fulltext, value: ->(manifestation) {manifestation.to_plaintext}
    field :genre, value: ->(manifestation) { manifestation.expressions[0].works[0].genre}, type: 'keyword'
    field :orig_lang, value: ->(manifestation) { manifestation.expressions[0].works[0].orig_lang}, type: 'keyword'
    field :orig_lang_title, value: ->(manifestation) { manifestation.expressions[0].works[0].origlang_title}, type: 'keyword'
    field :pby_publication_date, type: 'date', value: ->{created_at}
    field :author_string, value: ->(manifestation) {manifestation.author_string}
    field :author_ids, type: 'integer', value: ->(manifestation) {manifestation.author_and_translator_ids}
    field :title_and_authors, value: ->(manifestation) {manifestation.title_and_authors}
    field :impressions_count, type: 'integer'
    field :raw_publication_date, value: -> (manifestation) {manifestation.expressions[0].date}
    field :orig_publication_date, type: 'date', value: ->(manifestation) {normalize_date(manifestation.expressions[0].date)}
    # field :video_count, type: 'integer', value: ->(manifestation){ manifestation.video_count}
    # field :recommendation_count, type: 'integer', value: ->(manifestation){manifestation.recommendations.all_approved.count}
    #field :curated_content_count, type: 'integer', value: ->(manifestation){ 0 } # TODO: implement
    #field :tags, type: 'keyword', value: ->{ tags.map(&:name) }
    field :author_gender, value: ->(manifestation) {manifestation.author_gender }, type: 'keyword'
    field :translator_gender, value: ->(manifestation) {manifestation.translator_gender}, type: 'keyword'
    field :copyright_status, value: ->(manifestation) {manifestation.copyright?}, type: 'keyword' # TODO: make non boolean
    field :period, value: ->(manifestation) {manifestation.expressions[0].period}, type: 'keyword'
    field :raw_creation_date, value: ->(manifestation) {manifestation.expressions[0].works[0].date}
    field :creation_date, type: 'date', value: ->(manifestation) {normalize_date(manifestation.expressions[0].works[0].date)}
    field :place_and_publisher
  end

  # TODO: in future: collections/readers; users; recommendations; curated/featured content
end
