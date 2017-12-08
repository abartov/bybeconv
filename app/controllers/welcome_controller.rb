include BybeUtils
class WelcomeController < ApplicationController
  impressionist # log actions for pageview stats

  def index
    @totals = { works: get_total_works, authors: get_total_authors, headwords: get_total_headwords }
    @pop_authors = popular_authors
    @pop_authors_this_month = @pop_authors # Temporary hack! TODO: stop cheating and actually count by month
    @pop_works = popular_works
    @random_authors = randomize_authors(@pop_authors)
    @surprise_author = @random_authors.pop
    random_works = randomize_works(4) # TODO: un-hardcode?
    @random_work = random_works[0]
    @random_works = random_works[1..-1]
    @works_by_genre = count_works_by_genre
    @whatsnew = whatsnew_anonymous # TODO: custom calculate for logged-in users
    @featured_content = featured_content
    (@fc_snippet, @fc_rest) = snippet(@featured_content.body, 500) # prepare snippet for collapsible
    @featured_volunteer = featured_volunteer
    @popups_by_genre = popups_by_genre # cached, if available
    @pagetype = :homepage
    @page_title = t(:default_page_title)+' - '+t(:homepage)
    @tabclass = set_tab('home')
  end
end
