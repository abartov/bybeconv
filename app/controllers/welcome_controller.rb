include BybeUtils
class WelcomeController < ApplicationController
#  impressionist # log actions for pageview stats

  def index
    @tabclass = set_tab('home')
    @pagetype = :homepage
    @page_title = t(:default_page_title)+' - '+t(:homepage)

    @totals = { works: get_total_works, authors: get_total_authors, headwords: get_total_headwords }
    @pop_authors = popular_authors
    @pop_authors_this_month = @pop_authors # Temporary hack! TODO: stop cheating and actually count by month
    @pop_works = popular_works
    # @newest_authors = cached_newest_authors # deprecated because we stopped producing portraits
    @random_authors = Person.published.has_image.order(Arel.sql('RAND()')).limit(10)
    @newest_works = cached_newest_works
    @surprise_author = Person.where(id: Person.has_toc.pluck(:id).sample(1))[0]
    @surprise_work = randomize_works(1)[0]
    @authors_in_genre = cached_authors_in_genre
    @works_by_genre = Manifestation.cached_work_counts_by_genre
    @authors_in_period = cached_authors_in_period
    @works_by_period = cached_works_by_period
    # @whatsnew = whatsnew_anonymous # TODO: custom calculate for logged-in users
    @cached_newsfeed = cached_newsfeed # new, heterogeneous newsfeed
    @featured_content = featured_content
    (@fc_snippet, @fc_rest) = @featured_content.nil? ? ['',''] : snippet(@featured_content.body, 1500) # prepare snippet 
    @fc_snippet = MultiMarkdown.new(@fc_snippet).to_html.force_encoding('UTF-8') unless @fc_snippet.empty?
    @featured_author = featured_author
    (@fa_snippet, @fa_rest) = @featured_author.nil? ? ['',''] : snippet(@featured_author.body, 1500) # prepare snippet 
    @fa_snippet = MultiMarkdown.new(@fa_snippet).to_html.force_encoding('UTF-8') unless @fa_snippet.empty?
    @featured_volunteer = featured_volunteer
    # @popups_by_genre = popups_by_genre # cached, if available # used by older version of homepage
  end

  def featured_popup
    @featured_content = FeaturedContent.find(params[:id])
    if @featured_content.nil?
      head :ok
    else
      render partial: 'featured_item_popup'
    end
  end

  def featured_author_popup
    if params[:id].nil?
      head :not_found
    else
      @featured_author = FeaturedAuthor.find(params[:id])
      if @featured_author.nil?
        head :ok
      else
        render partial: 'featured_author_popup'
      end
    end
  end

  def contact
    render partial: 'contact'
  end

  def submit_contact
    @errors = []
    unless params[:ziburit] =~ /ביאליק/
      @errors << t('.ziburit_failed')
    end
    if params[:email].blank?
      @errors << t('.email_missing')
    end

    if @errors.empty?
      Notifications.contact_form_submitted(params.permit(:name, :phone, :email, :topic, :body, :rtopic)).deliver
    end
  end

  def volunteer
    respond_to do |format|
      format.js
    end
  end

  def submit_volunteer
    Notifications.volunteer_form_submitted(params.permit(:name, :phone, :email, :typing, :proofing, :scanning, :donation, :other)).deliver
    respond_to do |format|
      format.js
    end
  end

  private

  def featured_content
    Rails.cache.fetch("featured_content", expires_in: 10.minutes) do # memoize
      FeaturedContentFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).
        order(Arel.sql('RAND()')).
        first&.featured_content
    end
  end

  def featured_author
    Rails.cache.fetch("featured_author", expires_in: 1.hours) do # memoize
      FeaturedAuthorFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).
        order(Arel.sql('RAND()')).
        first&.featured_author
    end
  end

  def featured_volunteer
    Rails.cache.fetch("featured_volunteer", expires_in: 10.hours) do # memoize
      VolunteerProfileFeature.where("fromdate <= :now AND todate >= :now", now: Date.today).
        order(Arel.sql('RAND()')).
        first&.volunteer_profile
    end
  end
end
