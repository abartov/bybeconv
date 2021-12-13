class SearchManifestations < ApplicationService

  DIRECTIONS = %w(default asc desc)

  SORTING_PROPERTIES = {
    'alphabetical' => { default_dir: 'asc', column: :sort_title },
    'popularity' => { default_dir: 'desc', column: :impressions_count },
    'publication_date' => { default_dir: 'asc', column: :orig_publication_date },
    'creation_date' => { default_dir: 'asc', column: :creation_date },
    'upload_date' => { default_dir: 'desc', column: :pby_publication_date }
  }

  def call(sort_by, sort_dir, filters)
    filter = []

    add_simple_filter(filter, :genre, filters['genres'])
    add_simple_filter(filter, :period, filters['periods'])
    is_copyrighted = filters['is_copyrighted']

    unless is_copyrighted.nil?
      filter << { terms: { copyright_status: [is_copyrighted] } }
    end

    add_simple_filter(filter, :author_gender, filters['author_genders'])
    add_simple_filter(filter, :translator_gender, filters['translator_genders'])
    add_simple_filter(filter, :author_ids, filters['author_ids'])

    original_language = filters['original_language']
    if original_language.present?
      # xlat - is a magic constant meaning 'any language except hebrew'
      if original_language == 'xlat'
        filter << { bool: { must_not: { terms: { orig_lang: ['he'] } } } }
      else
        filter << { terms: { orig_lang: [original_language] } }
      end
    end

    add_date_range(filter, :pby_publication_date, filters['uploaded_between'])
    add_date_range(filter, :creation_date, filters['created_between'])
    add_date_range(filter, :orig_publication_date, filters['published_between'])

    author = filters['author']
    if author.present?
      filter << { match: { author_string: author } }
    end

    title = filters['title']
    if title.present?
      filter << { match_phrase: { title: title } }
    end

    result = ManifestationsIndex.filter(filter)

    fulltext = filters['fulltext']
    if fulltext.present?
      result = result.query({ match: { fulltext: fulltext } })
    else
      # we're only applying sorting if no full-text search is performed, because for full-text search we want to keep
      # relevance sorting
      sort_props = SORTING_PROPERTIES[sort_by]
      if sort_dir == 'default'
        sort_dir = sort_props[:default_dir]
      end
      # We additionally sort by id to order records with equal values in main sorting column
      result = result.order([ { sort_props[:column] => sort_dir }, { id: sort_dir } ])
    end

    return  result
  end

  private

  def add_simple_filter(list, field, value)
    return if value.blank?
    list << { terms: { field => value } }
  end

  def add_date_range(list, field, range_param)
    return if range_param.nil? || range_param.empty?
    range_expr = {}
    year = range_param['from']
    # Greater than or equal to first day of from-year
    range_expr['gte'] = Time.new(year, 1, 1, 0, 0, 0) if year.present?
    year = range_param['to']
    range_expr['lt'] = Time.new(year + 1, 1, 1, 0, 0, 0) if year.present?
    # Less than first day of year next to to-year
    unless range_expr.empty?
      list << { range: { field => range_expr } }
    end
  end
end
