# frozen_string_literal: true

class InvalidateEpubMobiCache < ActiveRecord::Migration[8.0]
  def change
    # Invalidate the cache for all EPUB and MOBI downloadables
    print "Removing stale/broken EPUB and MOBI downloadables... "
    Downloadable.where(doctype: %w[epub mobi]).destroy_all
    puts "done."
  end
end
