include BybeUtils
class WelcomeController < ApplicationController
  impressionist # log actions for pageview stats

  def index
    @tabclass = set_tab('home')
    @pagetype = :homepage
    @page_title = t(:default_page_title)+' - '+t(:homepage)

    @totals = { works: get_total_works, authors: get_total_authors, headwords: get_total_headwords }
    @pop_authors = popular_authors
    @pop_authors_this_month = @pop_authors # Temporary hack! TODO: stop cheating and actually count by month
    @pop_works = popular_works
    @newest_authors = cached_newest_authors
    @newest_works = cached_newest_works
    @surprise_author = Person.where(id: Person.has_toc.pluck(:id).sample(1))[0]
    @surprise_work = randomize_works(1)[0]
    @authors_in_genre = cached_authors_in_genre
    @works_by_genre = Manifestation.cached_work_counts_by_genre
    @authors_in_period = cached_authors_in_period
    @works_by_period = cached_works_by_period
    @whatsnew = whatsnew_anonymous # TODO: custom calculate for logged-in users
    @cached_newsfeed = cached_newsfeed # new, heterogeneous newsfeed
    @featured_content = featured_content
    (@fc_snippet, @fc_rest) = @featured_content.nil? ? ['',''] : snippet(@featured_content.body, 500) # prepare snippet for collapsible
    @featured_volunteer = featured_volunteer
    @popups_by_genre = popups_by_genre # cached, if available
  end
end
