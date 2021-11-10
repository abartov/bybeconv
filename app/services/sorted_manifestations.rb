class SortedManifestations < ApplicationService
  DIRECTIONS = %w(default asc desc)

  SORTING_PROPERTIES = {
    'alphabetical' => { default_dir: 'asc', column: :sort_title },
    'popularity' => { default_dir: 'desc', column: :impressions_count },
    'publication_date' => { default_dir: 'asc', column: 'expressions.normalized_pub_date' },
    'creation_date' => { default_dir: 'asc', column: 'works.normalized_creation_date' },
    'upload_date' => { default_dir: 'desc', column: :created_at }
  }

  def call(sort_by, sort_dir)
    sort_props = SORTING_PROPERTIES[sort_by]
    if sort_dir == 'default'
      sort_dir = sort_props[:default_dir]
    end
    rel = Manifestation.all
    if sort_by == 'publication_date'
      rel = rel.joins(:expressions)
    elsif sort_by == 'creation_date'
      rel = rel.joins(expressions: :works)
    end
    # We additionally sort by id to order records with equal values in main sorting column
    return rel.order("#{sort_props[:column]} #{sort_dir}, id #{sort_dir}")
  end
end