class ManifestationsIndex < Chewy::Index

  # works
  define_type Manifestation.all_published.joins([expressions: :works]).includes([expressions: :works]) do
#    field :title, analyzer: 'hebrew' # from https://github.com/synhershko/elasticsearch-analysis-hebrew
#    field :fulltext, value: ->(manifestation) {manifestation.to_plaintext}, analyzer: 'hebrew'
    field :title
    field :fulltext, value: ->(manifestation) {manifestation.to_plaintext}
    field :genre, value: ->(manifestation) { manifestation.expressions[0].works[0].genre}
    field :orig_lang, value: ->(manifestation) { manifestation.expressions[0].works[0].orig_lang}
    field :pby_publication_date, type: 'date', value: ->{created_at}
    field :author_string, value: ->(manifestation) {manifestation.author_string}
    field :orig_publication_date, value: ->(manifestation) {manifestation.expressions[0].date}
    field :video_count, type: 'integer', value: ->(manifestation){ manifestation.video_count}
    field :recommendation_count, type: 'integer', value: ->(manifestation){manifestation.recommendations.all_approved.count}
    field :curated_content_count, type: 'integer', value: ->(manifestation){ 0 } # TODO: implement
    field :tags, type: 'keyword', value: ->{ tags.map(&:name) }
    field :author_gender, value: ->(manifestation) {manifestation.author_gender }
    field :translator_gender, value: ->(manifestation) {manifestation.translator_gender}
    field :copyright_status, value: ->(manifestation) {manifestation.copyright?} # TODO: make non boolean
    field :period, value: ->(manifestation) {manifestation.expressions[0].period}
    field :creation_date, value: ->(manifestation) {manifestation.expressions[0].works[0].date}
  end

  # TODO: in future: collections/readers; users; recommendations; curated/featured content
end
