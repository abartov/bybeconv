class SearchController < ApplicationController
  def index
  end

  def results
    begin
      @searchterm = params[:search].nil? ? sanitize_term(params[:q]) : sanitize_term(params[:search])
      @search = params[:search].present? ? SiteWideSearch.new(@searchterm) : SiteWideSearch.new(query: @searchterm)

      @results = @search.search.page(params[:page])
      page = (params[:page] || 1).to_i
      @offset = (page - 1) * Kaminari.config.default_per_page
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
    return term.gsub(/(\S)\"(\S)/,'\1\2').gsub('׳',"'").gsub('״','"')
  end
end
