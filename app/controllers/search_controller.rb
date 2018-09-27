class SearchController < ApplicationController
  impressionist # log actions for pageview stats

  def index
  end

  def results
    @search = ManifestationsSearch.new(params[:search])
    @results = @search.search.page(params[:page])
    @total = @results.count
  end

  def advanced
  end
end
