class SearchController < ApplicationController
  impressionist # log actions for pageview stats

  def index
  end

  def results
    begin
      @search = ManifestationsSearch.new(params[:search])
      @results = @search.search.page(params[:page])
      @total = @results.count
    rescue # Faraday::Error::ConnectionFailed => e
      @total = -1
      @errmsg = $!
    end
  end

  def advanced
  end
end
