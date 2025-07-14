# frozen_string_literal: true

namespace :collections do
  desc 'Resolves collisions on seqno among colleciton items'
  task fix_ordering: :environment do
    collection_ids = Collection.joins(:collection_items)
                               .group('collections.id, collection_items.seqno')
                               .having('count(*) > 1')
                               .pluck('collections.id')

    collection_errors_count = {}
    collection_ids.each do |collection_id|
      fix_count = FixCollectionOrdering.call(collection_id)
      collection_errors_count[collection_id] = fix_count
      puts "Collection ##{collection_id}: #{fix_count} collisions fixed"
    end

    unless collection_errors_count.empty?
      CollectionsMailer.ordering_fixed(collection_errors_count).deliver_now
    end
  end
end
