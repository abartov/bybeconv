include BybeUtils
class WelcomeController < ApplicationController
  impressionist # log actions for pageview stats

  def index
    @totals = { works: get_total_works, authors: get_total_authors, headwords: get_total_headwords }
    @pop_authors = popular_authors

    @pagetype = :homepage
    @page_title = t(:default_page_title)+' - '+t(:homepage)
  end
end
