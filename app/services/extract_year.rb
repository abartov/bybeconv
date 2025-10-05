# frozen_string_literal: true

# Extracts year from the string representing date
class ExtractYear < ApplicationService
  # @param datestr string representing date to be parsed
  # @param default value to return if year cannot be extracted
  def call(datestr, default = '')
    return default if datestr.blank?

    pos = datestr.strip_hebrew.index('-') # YYYYMMDD or YYYY is assumed
    return datestr[0..(pos - 1)].strip unless pos.nil?
    return ::Regexp.last_match(0) if datestr =~ /\d\d\d+/

    return datestr
  end
end
