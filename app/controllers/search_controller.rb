class SearchController < ApplicationController
  impressionist # log actions for pageview stats

  def index
  end

  def results
    begin
      unless params[:search].nil?
        @search = ManifestationsSearch.new(params[:search])
      else
        @search = ManifestationsSearch.new(query: params[:q])
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
end
