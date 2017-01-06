include BybeUtils
class WelcomeController < ApplicationController
  def index
    @totals = { works: get_total_works, authors: get_total_authors, headwords: get_total_headwords }
    @pagetype = :homepage
    @page_title = t(:default_page_title)+' - '+t(:homepage)
  end
end
