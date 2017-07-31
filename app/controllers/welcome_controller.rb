include BybeUtils
class WelcomeController < ApplicationController
  impressionist # log actions for pageview stats

  def index
    @totals = { works: get_total_works, authors: get_total_authors, headwords: get_total_headwords }
    @pop_authors = popular_authors.map{|a| a[0]} # we don't need the actual counts here
    @pop_authors_this_month = @pop_authors # Temporary hack! TODO: stop cheating and actually count by month
    @pop_works = popular_works.map{|a| a[0]} # ditto
    @random_authors = randomize_authors(@pop_authors)
    @random_works = randomize_works(4) # TODO: un-hardcode?
    @works_by_genre = count_works_by_genre
    @whatsnew = whatsnew_anonymous # TODO: custom calculate for logged-in users
    @pagetype = :homepage
    @page_title = t(:default_page_title)+' - '+t(:homepage)
    @tabclass = set_tab('home')
  end
end
