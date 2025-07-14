# frozen_string_literal: true

# Service ensures all items in collection has unique seqno values and resolves collisions if found
class FixCollectionOrdering < ApplicationService
  # @return number of fixed seqno collisions
  def call(collection_id)
    collection = Collection.find(collection_id)
    prev_seqno = -1000 # nonexistant value
    fix_count = 0

    collection.collection_items.order(:seqno, :id).each_with_index do |ci, index|
      fix_count += 1 if ci.seqno == prev_seqno
      prev_seqno = ci.seqno
      ci.seqno = index + 1
      ci.save!
    end

    return fix_count
  end
end
