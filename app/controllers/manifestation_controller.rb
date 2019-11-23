require 'pandoc-ruby'

class ManifestationController < ApplicationController
  before_action only: [:list, :show, :remove_link, :edit_metadata] do |c| c.require_editor('edit_catalog') end
  before_action only: [:edit, :update] do |c| c.require_editor(['edit_catalog', 'conversion_verification', 'handle_proofs']) end

  autocomplete :manifestation, :title, limit: 20, display_value: :title_and_authors, full: true
  autocomplete :person, :name, :limit => 2, full: true
  autocomplete :tag, :name

  #impressionist :actions=>[:read,:readmode, :print, :download] # log actions for pageview stats

  #layout false, only: [:print]

  #############################################
  # public actions
  def all
    @page_title = t(:all_works)+' '+t(:project_ben_yehuda)
    @pagetype = :works
    # test @collection = Manifestation.all_published.order(:sort_title).limit(100)
    @collection = Manifestation.all_published
    browse
  end

  def browse
    prep_for_browse
    render :browse
    respond_to do |format|
      format.html
      format.js
    end
  end

  def by_tag
    @page_title = t(:works_by_tag)+' '+t(:project_ben_yehuda)
    @pagetype = :works
    @tag = Tag.find(params[:id])
    if @tag
      @works_by_tag = Manifestation.by_tag(params[:id]).order(:sort_title).page(params[:page]).limit(25)
    else
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    end
  end

  def autocomplete_works_by_author
    term = params[:term]
    author = params[:author]
    if term && author && !term.blank? && !author.blank?
      items = Person.find(author.to_i).all_works_by_title(term)
    else
      items = {}
    end

    render :json => json_for_autocomplete(items, :title_and_authors, {}), root: false
  end

  def periods # /periods dashboard
    @tabclass = set_tab('periods')
    @page_title = t(:periods)+' - '+t(:project_ben_yehuda)
    @pagetype = :periods
  end

  def works # /works dashboard
    @tabclass = set_tab('works')
    @page_title = t(:works)+' - '+t(:project_ben_yehuda)
    @pagetype = :works
    @work_stats = {total: Manifestation.cached_count, pd: Manifestation.cached_pd_count, translated: Manifestation.cached_translated_count}
    @work_stats[:permission] = @work_stats[:total] - @work_stats[:pd]
    @work_counts_by_genre = Manifestation.cached_work_counts_by_genre
    @pop_by_genre = Manifestation.cached_popular_works_by_genre # get popular works by genre + most popular translated
    @rand_by_genre = {}
    @surprise_by_genre = {}
    get_genres.each do |g|
      @rand_by_genre[g] = Manifestation.randomize_in_genre_except(@pop_by_genre[g][:orig], g) # get random works by genre
      @surprise_by_genre[g] = @rand_by_genre[g].pop # make one of the random works the surprise work
    end
    @works_abc = Manifestation.first_25 # get cached first 25 manifestations
    @new_works_by_genre = Manifestation.cached_last_month_works
    @featured_content = featured_content
    (@fc_snippet, @fc_rest) = @featured_content.nil? ? ['',''] : snippet(@featured_content.body, 500) # prepare snippet for collapsible
    @popular_tags = cached_popular_tags
  end

  def whatsnew
    @tabclass = set_tab('works')
    @page_title = t(:whatsnew)
    @whatsnew = []
    @anonymous = true
    if params['months'].nil? or params['months'].empty?
      @whatsnew = whatsnew_anonymous
    else
      @whatsnew = whatsnew_since(params[:months].to_i.months.ago)
      @anonymous = false
    end
    @new_authors = Person.new_since(1.month.ago)
  end

  def like
    unless current_user.nil?
      @m = Manifestation.find(params[:id])
      @m.likers << current_user
    end
    head :ok
  end

  def unlike
    unless current_user.nil?
      @m = Manifestation.find(params[:id])
      @m.likers.delete(current_user) # safely fails if already deleted
    end
    head :ok
  end

  def read
    prep_for_read
    unless @m.nil?
      @proof = Proof.new
      @new_recommendation = Recommendation.new
      @tagging = Tagging.new
      @tagging.manifestation_id = @m.id
      @tagging.suggester = current_user
      @taggings = @m.taggings
      @recommendations = @m.recommendations
      @links = @m.external_links.group_by {|l| l.linktype}
      @random_work = Manifestation.where(id: Manifestation.pluck(:id).sample(5), status: Manifestation.statuses[:published])[0]
      @header_partial = 'manifestation/work_top'
      @works_about = Work.joins(:topics).where('aboutnesses.aboutable_id': @w.id) # TODO: accommodate works about *expressions* (e.g. an article about a *translation* of Homer's Iliad, not the Iliad)
      @scrollspy_target = 'chapternav'
      prep_user_content
    end
  end

  def readmode
    @readmode = true
    prep_for_read
  end

  def print
    @print = true
    prep_for_print
    @footer_url = url_for(action: :read, id: @m.id)
  end

  def download
    @m = Manifestation.find(params[:id])
    impressionist(@m) unless is_spider?
    filename = "#{@m.safe_filename}.#{params[:format]}"
    html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"he\" lang=\"he\" dir=\"rtl\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head><body dir='rtl' align='right'><div dir=\"rtl\" align=\"right\">#{@m.title_and_authors_html}"+MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'')+"\n\n<hr />"+I18n.t(:download_footer_html, url: url_for(action: :read, id: @m.id))+"</div></body></html>"
    do_download(params[:format], filename, html, @m)
  end

  def render_html
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
  end

  def period
    @tabclass = set_tab('works')
    @manifestations = Manifestation.all_published.joins(:expressions).where(expressions: {period: Person.periods[params[:period]]}).page(params[:page]).order('sort_title ASC')
  end

  def genre
    @tabclass = set_tab('works')
    @manifestations = Manifestation.all_published.joins(:expressions).where(expressions: {genre: params[:genre]}).page(params[:page]).order('sort_title ASC')
  end

  # this one is called via AJAX
  def get_random
    work = nil
    unless params[:genre].nil? || params[:genre].empty?
      work = randomize_works_by_genre(params[:genre], 1)[0]
    else
      work = randomize_works(1)[0]
    end
    render partial: 'shared/surprise_work', locals: {passed_mode: params[:mode], manifestation: work, id_frag: params[:id_frag], passed_genre: params[:genre], side: params[:side]}
  end

  def surprise_work
    work = Manifestation.all_published.order(Arel.sql('RAND()')).limit(1)[0]
    render partial: 'surprise_work', locals: {work: work}
  end

  def workshow # temporary action to map to the first manifestation of the work; # TODO: in the future, show something intelligent about multiple expressions per work
    work = Work.find(params[:id])
    unless work.nil?
      m = work.expressions[0].manifestations[0]
      redirect_to action: :read, id: m.id
    else
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    end
  end

  #############################################
  # editor actions

  def remove_image
    @m = Manifestation.find(params[:id])
    did_something = false
    if @m.images.attached?
      rec = @m.images.where(id: params[:image_id])
      unless rec.empty?
        rec[0].purge
        did_something = true
      end
    end
    if did_something
      @img_id = params[:image_id]
      respond_to do |format|
        format.js
      end
    else
      head :ok
    end
  end

  def remove_link
    @m = Manifestation.find(params[:id])
    l = @m.external_links.where(id: params[:link_id])
    unless l.empty?
      l[0].destroy
      flash[:notice] = t(:deleted_successfully)
    else
      flash[:error] = t(:no_such_item)
    end
    redirect_to action: :show, id: params[:id]
  end

  def list
    # calculations
    @page_title = t(:catalog_title)
    @total = Manifestation.count
    # form input
    unless params[:commit].blank?
      session[:mft_q_params] = params.permit([:title, :author, :page]) # make prev. params accessible to view
    else
      session[:mft_q_params] = { title: '', author: '' }
    end
    @urlbase = url_for(action: :show, id:1)[0..-2]
    # DB
    if params[:title].blank? && params[:author].blank?
      @manifestations = Manifestation.page(params[:page]).order('updated_at DESC')
    else
      if params[:author].blank?
        @manifestations = Manifestation.where('title like ?', '%' + params[:title] + '%').page(params[:page]).order('sort_title ASC')
      elsif params[:title].blank?
        @manifestations = Manifestation.where('cached_people like ?', "%#{params[:author]}%").page(params[:page]).order('sort_title asc')
      else # both author and title
        @manifestations = Manifestation.where('manifestations.title like ? and manifestations.cached_people like ?', '%' + params[:title] + '%', '%'+params[:author]+'%').page(params[:page]).order('sort_title asc')
      end
    end
  end

  def show
    @m = Manifestation.find(params[:id])
    @page_title = t(:show)+': '+@m.title_and_authors
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
    @html = highlight_suspicious_markdown(@html) # highlight suspicious markdown in backend
    h = @m.legacy_htmlfile
    unless h.nil? or h.url.nil? or h.url.empty?
      @legacy_url = 'http://benyehuda.org'+h.url
    end
  end

  def edit
    @m = Manifestation.find(params[:id])
    @page_title = t(:edit_markdown)+': '+@m.title_and_authors
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
    @html = highlight_suspicious_markdown(@html) # highlight suspicious markdown in backend
    @markdown = @m.markdown
    h = @m.legacy_htmlfile
    unless h.nil? or h.url.nil? or h.url.empty?
      @legacy_url = 'http://benyehuda.org'+h.url
    end
  end

  def edit_metadata
    @m = Manifestation.find(params[:id])
    @page_title = t(:edit_metadata)+': '+@m.title_and_authors
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
  end

  def add_aboutnesses
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
    @page_title = t(:add_aboutnesses)+': '+@m.title_and_authors
    @aboutness = Aboutness.new
  end

  def add_images
    @m = Manifestation.find(params[:id])
    prev_count = @m.images.count
    @m.images.attach(params.permit(images: [])[:images])
    new_count = @m.images.count
    flash[:notice] = I18n.t(:uploaded_images, {images_added: new_count - prev_count, total: new_count})
    redirect_to action: :show, id: @m.id
  end

  def update
    @m = Manifestation.find(params[:id])
    # update attributes
    if params[:commit] == t(:save)
      Chewy.strategy(:atomic) {
          if params[:markdown].nil? # metadata edit
          @e = @m.expressions[0] # TODO: generalize?
          @w = @e.works[0] # TODO: generalize!
          @w.title = params[:wtitle]
          @w.genre = params[:genre]
          @w.orig_lang = params[:wlang]
          @w.origlang_title = params[:origlang_title]
          @w.date = params[:wdate]
          @w.comment = params[:wcomment]
          unless params[:add_person_w].blank?
            c = Creation.new(work_id: @w.id, person_id: params[:add_person_w], role: params[:role_w].to_i)
            c.save!
          end
          @e.language = params[:elang]
          @e.genre = params[:genre] # expression's genre is same as work's
          @e.title = params[:etitle]
          @e.date = params[:edate]
          @e.comment = params[:ecomment]
          @e.copyrighted = (params[:public_domain] == 'false' ? true : false) # field name semantics are flipped from param name, yeah
          unless params[:add_person_e].blank?
            r = Realizer.new(expression_id: @e.id, person_id: params[:add_person_e], role: params[:role_e].to_i)
            r.save!
          end
          @e.source_edition = params[:source_edition]
          @m.title = params[:mtitle]
          @m.responsibility_statement = params[:mresponsibility]
          @m.comment = params[:mcomment]
          @m.status = params[:mstatus].to_i
          unless params[:add_url].blank?
            l = ExternalLink.new(url: params[:add_url], linktype: params[:link_type], description: params[:link_description], status: Manifestation.linkstatuses[:approved])
            l.manifestation = @m
            l.save!
          end
          @w.save!
          @e.save!
        else # markdown edit and save
          unless params[:newtitle].nil? or params[:newtitle].empty?
            @e = @m.expressions[0] # TODO: generalize?
            @w = @e.works[0] # TODO: generalize!
            @m.title = params[:newtitle]
            @e.title = params[:newtitle]
            @w.title = params[:newtitle] if @w.orig_lang == @e.language # update work title if work in Hebrew
            @e.save!
            @w.save!
          end
          @m.markdown = params[:markdown]
          @m.conversion_verified = params[:conversion_verified]
        end
        @m.recalc_cached_people
        @m.recalc_heading_lines
        @m.save!
        if current_user.has_bit?('edit_catalog')
          redirect_to action: :show, id: @m.id
        else
          redirect_to controller: :admin, action: :index
        end
        flash[:notice] = I18n.t(:updated_successfully)
      }
    elsif params[:commit] == t(:preview)
      @m = Manifestation.find(params[:id])
      @page_title = t(:edit_markdown)+': '+@m.title_and_authors
      @html = MultiMarkdown.new(params[:markdown]).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
      @html = highlight_suspicious_markdown(@html) # highlight suspicious markdown in backend
      @markdown = params[:markdown]
      @newtitle = params[:newtitle]

      h = @m.legacy_htmlfile
      unless h.nil? or h.url.nil?
        @legacy_url = 'https://benyehuda.org'+h.url
      end
      render action: :edit
    end
  end

  protected

  def prep_for_browse
    @total = @collection.count
    @page = params[:page] || 1
    @total_pages = @collection.page(params[:page]).total_pages
    @works_abc = @collection.order(:sort_title).page(params[:page]).limit(100) # get page X of all manifestations
    @header_partial = 'manifestation/browse_top'
    @ab = prep_ab
  end

  def prep_ab
    ret = []
    abc_present = @collection.pluck(:sort_title).map{|t| t[0] || ''}.uniq.sort
    ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ', 'ק', 'ר', 'ש', 'ת'].each{|l|
      status = abc_present.include?(l) ? '' : :disabled
      ret << [l, status]
    }
    return ret
  end

  def prep_user_content
    if current_user
      @anthologies = current_user.anthologies

      if session[:current_anthology_id].nil?
        unless @anthologies.empty?
          @anthology = @anthologies.includes(:texts).first
          session[:current_anthology_id] = @anthology.id
        end
      else
        begin
          @anthology = Anthology.find(session[:current_anthology_id])
        rescue
          session[:current_anthology_id] = nil # if somehow deleted without resetting the session variable (e.g. during development)
        end
      end
      @anthology_select_options = @anthologies.map{|a| [a.title, a.id, @anthology == a ? 'selected' : ''] }
      @cur_anth_id = @anthology.nil? ? 0 : @anthology.id
    end
  end

  def prep_for_print
    @m = Manifestation.find(params[:id])
    if @m.nil?
      head :ok
    else
      @e = @m.expressions[0]
      @w = @e.works[0]
      @author = @w.persons[0] # TODO: handle multiple authors
      unless is_spider?
        impressionist(@m)
        unless @author.nil?
          impressionist(@author) # also increment the author's popularity counter
        end
      end
      if @author.nil?
        @author = Person.new(name: '?')
      end
      @translators = @m.translators
      @page_title = "#{@m.title_and_authors} - #{t(:default_page_title)}"
      if @print
        @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
      end
    end
  end

  def prep_for_read
    @print = false
    prep_for_print
    unless @m.nil?
      lines = @m.markdown.lines
      tmphash = {}
      @chapters = [] # TODO: add sub-chapters, indenting two nbsps in dropdown

      ## div-wrapping chapters, trying to debug the scrollspy...
      #first = true
      #@m.heading_lines.reverse.each{ |linenum|
      #  insert_text = "<div id=\"ch#{linenum}\" role=\"tabpanel\"> <a name=\"ch#{linenum}\"></a>\r\n"
      #  unless first
      #    insert_text = "</div>" + insert_text
      #  else
      #    first = false
      #  end
      #  lines.insert(linenum, insert_text)
      #  # lines.insert(linenum, "\n<p id=\"ch#{linenum}\"></p>\r\n")
      #  tmphash[sanitize_heading(lines[linenum+1][2..-1].strip)] = linenum.to_s
      #} # annotate headings in reverse order, to avoid offsetting the next heading
      #lines << "</div>\n" unless first # close final section if any headings existed in the text
      ch_count = 0
      @m.heading_lines.reverse.each{ |linenum|
        ch_count += 1
        insert_text = "<a name=\"ch#{linenum}\" class=\"ch_anch\" id=\"ch#{linenum}\">&nbsp;</a>\r\n"
        lines.insert(linenum, insert_text)
        tmphash[ch_count.to_s.rjust(4, "0")+sanitize_heading(lines[linenum+1][2..-1].strip)] = linenum.to_s
      } # annotate headings in reverse order, to avoid offsetting the next heading
      tmphash.keys.reverse.map{|k| @chapters << [k[4..-1], tmphash[k]]}
      @selected_chapter = tmphash.keys.last
      @html = MultiMarkdown.new(lines.join('')).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
      @tabclass = set_tab('works')
      @entity = @m
      @pagetype = :manifestation
      @print_url = url_for(action: :print, id: @m.id)
      @liked = (current_user.nil? ? false : @m.likers.include?(current_user))
      if @e.translation?
        if @e.works[0].expressions.count > 1 # one is the one we're looking at...
          @additional_translations = []
          @e.works[0].expressions.joins(:manifestations).includes(:manifestations).each do |ex|
            @additional_translations << ex unless ex == @e
          end
        end
      end
    end
  end
end
