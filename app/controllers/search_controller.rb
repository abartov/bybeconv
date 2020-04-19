class SearchController < ApplicationController
  impressionist # log actions for pageview stats

  def index
  end

  def results
    begin
      unless params[:search].nil?
        @search = ManifestationsSearch.new(sanitize_term(params[:search]))
      else
        @search = ManifestationsSearch.new(query: sanitize_term(params[:q]))
      end
      @results = @search.search.page(params[:page])
      @total = @results.count
    rescue # Faraday::Error::ConnectionFailed => e
      @total = -1
      @errmsg = $!
    end
  end

  def advanced
  end

  protected

  def sanitize_term(term)
    # TODO: do this more intelligently, to still allow searching for phrases.  We only want to replace quotation marks inside words, so we need a regexp here.
    return term.gsub('"', ' ')
  end
end
