TAGGING_LOCK = '/tmp/tagging.lock'
TAGGING_LOCK_TIMEOUT = 15 # 15 minutes
PROGRESS_SERIES = [5, 10, 25, 50, 75, 100, 150, 200, 300, 400, 500, 750, 1000, 1250, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 7000, 8000, 9000, 10000, 12000, 14000, 16000, 18000, 20000]

class AdminController < ApplicationController
  before_action :require_editor
  before_action :obtain_tagging_lock, only: [:approve_tag, :approve_tag_and_next, :reject_tag, :escalate_tag, :reject_tag_and_next, :merge_tag, :merge_tagging, :approve_tagging, :reject_tagging, :escalate_tagging, :unapprove_tagging, :unreject_tagging, :tag_moderation, :tag_review]
  # before_action :require_admin, only: [:missing_languages, :missing_genres, :incongruous_copyright, :missing_copyright, :similar_titles]
  autocomplete :manifestation, :title, display_value: :title_and_authors, extra_data: [:expression_id] # TODO: also search alternate titles!
  autocomplete :person, :name, full: true
  autocomplete :collection, :title, full: true, display_value: :title_and_authors
  layout false, only: [:merge_tag, :merge_tagging, :confirm_with_comment] # popups
  layout 'backend', only: [:tag_moderation, :tag_review, :tagging_review] # eventually change to except: [<popups>]

  def index
    if current_user && current_user.editor?
      if current_user.has_bit?('handle_proofs')
        @open_proofs = Proof.where(status: 'new').count.to_s
        @escalated_proofs = Proof.where(status: 'escalated').count.to_s
      end
      if current_user.has_bit?('edit_catalog')
        @current_uploads = HtmlFile.where(assignee: current_user, status: 'Uploaded')
      end
      if current_user.has_bit?('moderate_tags')
        @pending_tags = Tag.where(status: :pending).count
        @pending_taggings = Tagging.where(status: :pending).count
      end
      @open_recommendations = LegacyRecommendation.where(status: 'new').count.to_s
      @conv_todo = Manifestation.where(conversion_verified: false, status: Manifestation.statuses[:published]).count
      @manifestation_count = Manifestation.published.count
      @conv_percent_done = (@manifestation_count - @conv_todo) / @manifestation_count.to_f * 100
      @page_title = t(:dashboard)
      @search = ManifestationsSearch.new(query: '')
    end
  end

  ##############################################
  ## Reports
  def raw_tocs
    @authors = Person.joins(:toc).where('tocs.status = 0').page(params[:page]).per(15)
    @total = Person.joins(:toc).where('tocs.status = 0').count
    @page_title = t(:raw_tocs)
    Rails.cache.write('report_raw_tocs', @total)
  end

  def messy_tocs
    @authors = []
    Person.has_toc.joins(:toc).includes(:toc).each do |p|
      unless p.toc.structure_okay?
        @authors << p
      end
    end
    Rails.cache.write('report_messy_tocs', @authors.count)
  end

  def missing_languages
    ex = Expression.joins([:involved_authorities, :work]).where(involved_authorities: {role: :translator}, works: {orig_lang: 'he'})
    mans = ex.map{|e| e.manifestations[0]}
    @total = mans.length
    @mans = Kaminari.paginate_array(mans).page(params[:page]).per(50)
    @page_title = t(:missing_language_report)
    Rails.cache.write('report_missing_languages', mans.length)
  end

  def missing_genres
    missing_genres = Manifestation.genre(nil)
    @mans = missing_genres.page(params[:page]).per(50)
    @total = missing_genres.count
    @page_title = t(:missing_genre_report)
    Rails.cache.write('report_missing_genres', @total)
  end

  def missing_images
    @authors = Person.where(profile_image_file_name: nil).order('name asc')
    @page_title = t(:missing_images)
    Rails.cache.write('report_missing_images', @authors.count)
  end

  def missing_copyright
    @authors = Person.where(public_domain: nil)
    records = Manifestation.joins(:expression).where(expressions: {copyrighted: nil})
    @total = records.count
    @mans = records.page(params[:page]).per(50)
    @page_title = t(:missing_copyright_report)
    Rails.cache.write('report_missing_copyright', @total)
  end

  def similar_titles
    prefixes = {}
    @similarities = {}
    whitelisted_ids = ListItem.where(listkey: 'similar_title_whitelist').pluck(:item_id)
    Manifestation.all.each {|m|
      next if whitelisted_ids.include?(m.id) # skip whitelisted works
      prefix = [m.cached_people, m.title[0..(m.title.length > 8 ? 8 : -1)]]
      if prefixes[prefix].nil?
        prefixes[prefix] = [m]
      else
        prefixes[prefix] << m
      end
    }
    prefixes.each_pair{|k, v|
      next if v.length < 2
      @similarities[k] = v.sort_by{|m| m.title}
    }
    Rails.cache.write('report_similar_titles', @similarities.keys.length)
  end

  def mark_similar_as_valid
    m = Manifestation.find(params[:id])
    unless m.nil?
      li = ListItem.new(listkey: 'similar_title_whitelist', item: m)
      li.save!
    end
    head :ok
  end

  def suspicious_translations # find works where the author is also a translator -- this *may* be okay, in the case of self-translation, but probably is a mistake
    records = Manifestation.joins(expression: :work).joins("inner join involved_authorities ia_w on ia_w.item_id = works.id and ia_w.item_type = 'Work'").joins("inner join involved_authorities ia_e on ia_e.item_id = expressions.id and ia_e.item_type = 'Expression'").where("ia_w.authority_id = ia_e.authority_id and ia_w.authority_type = ia_e.authority_type and ia_w.role = #{InvolvedAuthority.roles[:author]} and ia_e.role = #{InvolvedAuthority.roles[:translator]}")
    @total = records.count
    @mans = records.page(params[:page])
    @page_title = t(:suspicious_translations_report)
    Rails.cache.write('report_suspicious_translations', @total)
  end

  def assign_proofs
    @p = Proof.where(status: 'new').order(created_at: :asc).limit(1).first
    if @p.nil?
      flash[:notice] = t(:no_more_items)
    else
      @p.status = 'assigned'
      @p.save!
      li = ListItem.new(listkey: 'proofs_by_user', user: current_user, item: @p)
      li.save!
      # check if there are any other proofs on this manifestation, and if so, assign them too, for efficiency
      other_proofs = []
      unless @p.manifestation_id.nil?
        other_proofs = Proof.where(status: 'new', manifestation_id: @p.manifestation_id)
      else
        other_proofs = Proof.where(status: 'new', about: @p.about)
      end
      other_proofs.each do |other|
        other.status = 'assigned'
        other.save
        li = ListItem.new(listkey: 'proofs_by_user', user: current_user, item: other)
        li.save!
      end
      li = ListItem.new(listkey: 'proofs_by_user', user: current_user, item: @p)
      li.save!
    end
    redirect_to url_for(action: :index)
  end

  def assign_conversion_verification
    @m = Manifestation.where(conversion_verified: false, status: Manifestation.statuses[:published]).order('RAND()').first
    if @m.conv_counter.nil?
      @m.conv_counter = 1
    else
      @m.conv_counter += 1
    end
    @m.save!
    li = ListItem.new(listkey: 'convs_by_user', user: current_user, item: @m)
    li.save!

    redirect_to url_for(controller: :manifestation, action: :edit, id: @m.id)
  end

  def conversion_verification
    @manifestations = Manifestation.where(conversion_verified: false).order(:title).page(params[:page])
    @total = Manifestation.where(conversion_verified: false).count
    @page_title = t(:conversion_verification_report)
    Rails.cache.write('report_conversion_verification', @total)
  end

  def my_convs
    @u = User.find(params[:id])
    if @u.nil?
      flash[:error] = t(:no_such_user)
      redirect_to action: :index
    else
      @items = ListItem.where(listkey: 'convs_by_user', user: @u)
    end
    render layout: false
  end

  def periodless
    @authors = Person.where(period: nil).select{|p| p.has_any_hebrew_works?}
    Rails.cache.write('report_periodless', @authors.length)
  end

  def authors_without_works
    @authors = nw = Person.left_joins(:involved_authorities).group('people.id').having('count(involved_authorities.id) = 0').order('people.name asc')
    Rails.cache.write('report_authors_without_works', @authors.length)
  end
  # this is a massive report that takes a long time to run!
  def tocs_missing_links
    @author_keys = []
    @tocs_missing_links = {}
    @tocs_linking_to_missing_items = {}
    Person.has_toc.each do |p|
      @tocs_missing_links[p.id] = {orig: [], xlat: []} if @tocs_missing_links[p.id].nil? # it may already exist because of being translated by an author we've already processed
      toc_items = []
      begin
        toc_items = p.toc.linked_items
      rescue ActiveRecord::RecordNotFound
        @tocs_linking_to_missing_items[p.id] = []
        found_item_ids = []
        p.toc.linked_item_ids.each do |mid|
          if Manifestation.exists?(mid)
            found_item_ids << mid
          else
            @tocs_linking_to_missing_items[p.id] << mid
          end
        end
        toc_items = Manifestation.find(found_item_ids)
      end
      p.original_works.each do |m|
        @tocs_missing_links[p.id][:orig] << m unless toc_items.include?(m)
      end
      p.translations.includes(expression: :work).each do |m|
        @tocs_missing_links[p.id][:xlat] << m unless toc_items.include?(m)
        # additionally, make sure they appear in the original author's ToC, if it's a manual one (relevant for translated authors who *also* wrote in Hebrew, e.g. Y. L. Perets)
        m.expression.work.authors.each do |au|
          unless au.toc.nil?
            unless au.toc.linked_item_ids.include?(m.id)
              @tocs_missing_links[au.id] = {orig: [], xlat: []} if @tocs_missing_links[au.id].nil?
              @tocs_missing_links[au.id][:orig] << m
            end
          end
        end
      end
      unless @tocs_missing_links[p.id][:orig] == [] && @tocs_missing_links[p.id][:xlat] == []
        @author_keys << p.id
      end
    end
    Rails.cache.write('report_tocs_missing_links', @author_keys.length)
  end

  def translated_from_multiple_languages
    @authors = []

    # Getting list of authors, who wrote works in more than one language
    translatees = Person.joins(involved_authorities: :work).
      merge(InvolvedAuthority.author).
      group('people.id').
      select('people.id, people.name').
      having('min(works.orig_lang) <> max(works.orig_lang)').
      sort_by(&:name)

    translatees.each do |t|
      manifestations = Manifestation.joins(expression: { work: :involved_authorities }).
        where(involved_authorities: {authority_id: t.id, authority_type: 'Person'}).
        preload(expression: :work).
        sort_by { |m| [m.expression.work.orig_lang, m.sort_title] }.
        group_by { |m| m.expression.work.orig_lang }
      @authors << [t, manifestations.keys, manifestations]
    end
    Rails.cache.write('report_translated_from_multiple_languages', @authors.length)
  end

  # We assume manifestation should be copyrighted if one of its creators or realizers is not in public domain
  CALCULATED_COPYRIGHT_EXPRESSION = <<~sql
    (
      exists (select 1 from involved_authorities c join people p on p.id = c.authority_id and c.authority_type = 'Person' where c.item_id = works.id and c.item_type = 'Work' and not coalesce(p.public_domain, false))
      or exists (select 1 from involved_authorities r join people p on p.id = r.authority_id and r.authority_type = 'Person' where r.item_id = expressions.id and not coalesce(p.public_domain, false))
    )
  sql

  def incongruous_copyright
    @incong = Manifestation.joins(expression: :work).
        select('manifestations.title, manifestations.id, manifestations.expression_id, expressions.copyrighted').
        select(Arel.sql("#{CALCULATED_COPYRIGHT_EXPRESSION} as calculated_copyright")).
        where("expressions.copyrighted is null or #{CALCULATED_COPYRIGHT_EXPRESSION} <> expressions.copyrighted").map do |m|
      [ m, m.title, m.author_string, m.calculated_copyright, m.copyrighted ]
    end

    Rails.cache.write('report_incongruous_copyright', @incong.length)
  end

  def texts_between_dates
    if params[:from].present? && params[:to].present?
      @texts = Manifestation.published.where('created_at > ? and created_at < ?', Date.parse(params[:from]), Date.parse(params[:to])).order(:created_at)
      @total = @texts.count
    end
  end
  def suspicious_titles
    @suspicious = Manifestation.where('(title like "%קבוצה %") OR (title like "%.") OR (title like "__")').select{|x| x.title !~ /\.\.\./}
    Rails.cache.write('report_suspicious_titles', @suspicious.length)
  end

  def suspicious_headings
    mm = Manifestation.where('length(cached_heading_lines)>3')
    @suspicious = []
    mm.each do |m|
      suspicious = false
      prev = -10
      m.cached_heading_lines.split('|').each do |l|
        line_no = l.to_i
        if line_no - prev < 5
          lines = m.markdown.split("\n")
          if lines[prev..line_no].join.length < 500 # probably too short for separate chapter/section
            suspicious = true
          end
        end
        prev = line_no
      end
      @suspicious << m if suspicious
    end
    Rails.cache.write('report_suspicious_headings', @suspicious.length)
  end

  #######################################
  ## Static pages management
  def static_pages_list
    @vps = StaticPage.page(params[:page])
  end

  def static_page_new
    @vp = StaticPage.new
    respond_to do |format|
      format.html
      format.json { render json: @vp }
    end
  end

  def static_page_create
    @vp = StaticPage.new(sp_params)
    respond_to do |format|
      if @vp.save
        @vp.images.attach(params[:static_page][:images]) if params[:static_page][:images].present?
        format.html { redirect_to url_for(action: :static_page_show, id: @vp.id), notice: t(:updated_successfully) }
        format.json { render json: @vp, status: :created, location: @vp }
      else
        format.html { render action: 'static_page_new'}
        format.json { render json: @vp.errors, status: :unprocessable_entity }
      end
    end
  end

  def static_page_show
    @vp = StaticPage.find(params[:id])
    if @vp.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
    @markdown = @vp.prepare_markdown
  end

  def static_page_edit
    @vp = StaticPage.find(params[:id])
  end

  def static_page_update
    @vp = StaticPage.find(params[:id])
    if @vp.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    else
      if @vp.update(sp_params)
        @vp.images.attach(params[:static_page][:images]) if params[:static_page][:images].present?
        flash[:notice] = I18n.t(:updated_successfully)
        redirect_to action: :static_page_show, id: @vp.id
      else
        format.html { render action: 'static_page_edit' }
        format.json { render json: @vp.errors, status: :unprocessable_entity }
      end
    end
  end


  #######################################
  ## Volunteer profiles management
  def volunteer_profiles_list
    @vps = VolunteerProfile.page(params[:page])
  end

  def volunteer_profile_new
    @vp = VolunteerProfile.new
    respond_to do |format|
      format.html
      format.json { render json: @vp }
    end
  end

  def volunteer_profile_create
    @vp = VolunteerProfile.new(vp_params)
    respond_to do |format|
      if @vp.save
        format.html { redirect_to url_for(action: :volunteer_profile_show, id: @vp.id), notice: t(:updated_successfully) }
        format.json { render json: @vp, status: :created, location: @vp }
      else
        format.html { render action: 'volunteer_profile_new'}
        format.json { render json: @vp.errors, status: :unprocessable_entity }
      end
    end
  end

  def volunteer_profile_show
    @vp = VolunteerProfile.find(params[:id])
    if @vp.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
  end

  def volunteer_profile_edit
    @vp = VolunteerProfile.find(params[:id])
  end

  def volunteer_profile_update
    @vp = VolunteerProfile.find(params[:id])
    if @vp.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    else
      if @vp.update(vp_params)
        flash[:notice] = I18n.t(:updated_successfully)
        redirect_to action: :volunteer_profile_show, id: @vp.id
      else
        format.html { render action: 'volunteer_profile_edit' }
        format.json { render json: @vp.errors, status: :unprocessable_entity }
      end
    end
  end

  def volunteer_profile_add_feature
    unless params[:fromdate].nil? or params[:todate].nil?
      vp = VolunteerProfile.find(params[:vpid])
      unless vp.nil?
        vpf = VolunteerProfileFeature.new(fromdate: Date.new(params[:fromdate][:year].to_i, params[:fromdate][:month].to_i, params[:fromdate][:day].to_i),
          todate: Date.new(params[:todate][:year].to_i, params[:todate][:month].to_i, params[:todate][:day].to_i))
        vpf.volunteer_profile = vp
        vpf.save!

        flash[:notice] = I18n.t(:created_successfully)
        redirect_to url_for(action: :volunteer_profile_show, id: params[:vpid].to_i)
      else
        flash[:error] = I18n.t(:no_such_item)
        redirect_to url_for(action: :index)
      end
    end
  end

  def volunteer_profile_delete_feature
    vpf = VolunteerProfileFeature.find(params[:id])
    unless vpf.nil?
      vpid = vpf.volunteer_profile_id
      vpf.destroy!
      flash[:notice] = I18n.t(:deleted_successfully)
      redirect_to url_for(action: :volunteer_profile_show, id: vpid)
    else
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
  end

  def volunteer_profile_destroy
    @vp = VolunteerProfile.find(params[:id])
    unless @vp.nil?
      @vp.destroy
    end
    flash[:notice] = I18n.t(:deleted_successfully)
    redirect_to action: :volunteer_profile_list
  end

  ########################################################
  ## featured content
  def featured_content_list
    @fcs = FeaturedContent.page(params[:page])
  end

  def featured_content_new
    @fc = FeaturedContent.new
    respond_to do |format|
      format.html
      format.json { render json: @fc }
    end
  end

  def featured_content_create
    @fc = FeaturedContent.new(fc_params)
    @fc.user = current_user
    unless params[:linked_manifestation].empty?
      @fc.manifestation = Manifestation.find(params[:linked_manifestation])
    end
    unless params[:linked_author].empty?
      @fc.person = Person.find(params[:linked_author])
    end

    respond_to do |format|
      if @fc.save
        format.html { redirect_to url_for(action: :featured_content_show, id: @fc.id), notice: t(:updated_successfully) }
        format.json { render json: @fc, status: :created, location: @fc }
      else
        format.html { render action: 'featured_content_new'}
        format.json { render json: @fc.errors, status: :unprocessable_entity }
      end
    end
  end

  def featured_content_show
    @fc = FeaturedContent.find(params[:id])
    if @fc.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
  end

  def featured_content_edit
    @fc = FeaturedContent.find(params[:id])
  end

  def featured_content_update
    @fc = FeaturedContent.find(params[:id])
    if @fc.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    else
      unless params[:linked_manifestation].empty?
        @fc.manifestation = Manifestation.find(params[:linked_manifestation])
      end
      unless params[:linked_author].empty?
        @fc.person = Person.find(params[:linked_author])
      end
      @fc.save
      if @fc.update(fc_params)
        flash[:notice] = I18n.t(:updated_successfully)
        redirect_to action: :featured_content_show, id: @fc.id
      else
        format.html { render action: 'featured_content_edit' }
        format.json { render json: @fc.errors, status: :unprocessable_entity }
      end
    end
  end

  def featured_content_destroy
    @fc = FeaturedContent.find(params[:id])
    unless @fc.nil?
      @fc.destroy
    end
    flash[:notice] = I18n.t(:deleted_successfully)
    redirect_to action: :featured_content_list
  end

  def featured_content_add_feature
    unless params[:fromdate].nil? or params[:todate].nil?
      fc = FeaturedContent.find(params[:fcid])
      unless fc.nil?
        fcf = FeaturedContentFeature.new(fromdate: Date.new(params[:fromdate][:year].to_i, params[:fromdate][:month].to_i, params[:fromdate][:day].to_i),
          todate: Date.new(params[:todate][:year].to_i, params[:todate][:month].to_i, params[:todate][:day].to_i))
        fcf.featured_content = fc
        fcf.save!

        flash[:notice] = I18n.t(:created_successfully)
        redirect_to url_for(action: :featured_content_show, id: fc.id)
      else
        flash[:error] = I18n.t(:no_such_item)
        redirect_to url_for(action: :index)
      end
    end
  end

  def featured_content_delete_feature
    fcf = FeaturedContentFeature.find(params[:id])
    unless fcf.nil?
      fcid = fcf.featured_content_id
      fcf.destroy!
      flash[:notice] = I18n.t(:deleted_successfully)
      redirect_to url_for(action: :featured_content_show, id: fcid)
    else
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
  end

  ## sitenotices
  def sitenotice_list
    @sns = Sitenotice.page(params[:page])
  end

  def sitenotice_new
    @sn = Sitenotice.new
    respond_to do |format|
      format.html
      format.json { render json: @sn }
    end
  end

  def sitenotice_create
    @sn = Sitenotice.new(body: sn_params[:body], status: (sn_params[:status] == '1' ? :enabled : :disabled))
    @sn.fromdate = Date.new(params[:fromdate][:year].to_i, params[:fromdate][:month].to_i, params[:fromdate][:day].to_i)
    @sn.todate = Date.new(params[:todate][:year].to_i, params[:todate][:month].to_i, params[:todate][:day].to_i)
    respond_to do |format|
      if @sn.save
        Rails.cache.delete("sitenotices") # clear cached sitenotices
        format.html { redirect_to url_for(action: :sitenotice_show, id: @sn.id), notice: t(:updated_successfully) }
        format.json { render json: @sn, status: :created, location: @sn }
      else
        format.html { render action: 'sitenotice_new'}
        format.json { render json: @sn.errors, status: :unprocessable_entity }
      end
    end
  end

  def sitenotice_show
    @sn = Sitenotice.find(params[:id])
    if @sn.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
  end

  def sitenotice_edit
    @sn = Sitenotice.find(params[:id])
  end

  def sitenotice_update
    @sn = Sitenotice.find(params[:id])
    @sn.body = sn_params[:body]
    @sn.status = (sn_params[:status] == '1' ? :enabled : :disabled)
    @sn.fromdate = Date.new(params[:fromdate][:year].to_i, params[:fromdate][:month].to_i, params[:fromdate][:day].to_i)
    @sn.todate = Date.new(params[:todate][:year].to_i, params[:todate][:month].to_i, params[:todate][:day].to_i)
    if @sn.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    else
      if @sn.save
        Rails.cache.delete("sitenotices") # clear cached sitenotices
        flash[:notice] = I18n.t(:updated_successfully)
        redirect_to action: :sitenotice_show, id: @sn.id
      else
        format.html { render action: 'sitenotice_edit' }
        format.json { render json: @sn.errors, status: :unprocessable_entity }
      end
    end
  end

  def sitenotice_destroy
    @sn = Sitenotice.find(params[:id])
    unless @sn.nil?
      @sn.destroy
      Rails.cache.delete("sitenotices") # clear cached sitenotices
    end
    flash[:notice] = I18n.t(:deleted_successfully)
    redirect_to action: :sitenotice_list
  end
  ########################################################
  ## featured author
  def featured_author_list
    @fcs = FeaturedAuthor.page(params[:page])
  end

  def featured_author_new
    @fc = FeaturedAuthor.new
    respond_to do |format|
      format.html
      format.json { render json: @fc }
    end
  end

  def featured_author_create
    @fc = FeaturedAuthor.new(fa_params)
    @fc.person_id = params[:person_id]
    @fc.user = current_user
    respond_to do |format|
      if @fc.save
        format.html { redirect_to url_for(action: :featured_author_show, id: @fc.id), notice: t(:updated_successfully) }
        format.json { render json: @fc, status: :created, location: @fc }
      else
        format.html { render action: 'featured_author_new'}
        format.json { render json: @fc.errors, status: :unprocessable_entity }
      end
    end
  end

  def featured_author_show
    @fc = FeaturedAuthor.find(params[:id])
    if @fc.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
  end

  def featured_author_edit
    @fc = FeaturedAuthor.find(params[:id])
  end

  def featured_author_destroy
    @fa = FeaturedAuthor.find(params[:id])
    unless @fa.nil?
      @fa.destroy
    end
    flash[:notice] = I18n.t(:deleted_successfully)
    redirect_to action: :featured_author_list
  end

  def featured_author_update
    @fc = FeaturedAuthor.find(params[:id])
    if @fc.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    else
      if @fc.update(fa_params)
        flash[:notice] = I18n.t(:updated_successfully)
        redirect_to action: :featured_author_show, id: @fc.id
      else
        format.html { render action: 'featured_author_edit' }
        format.json { render json: @fc.errors, status: :unprocessable_entity }
      end
    end
  end

  def featured_author_add_feature
    unless params[:fromdate].nil? or params[:todate].nil?
      fc = FeaturedAuthor.find(params[:fcid])
      unless fc.nil?
        fcf = FeaturedAuthorFeature.new(fromdate: Date.new(params[:fromdate][:year].to_i, params[:fromdate][:month].to_i, params[:fromdate][:day].to_i),
          todate: Date.new(params[:todate][:year].to_i, params[:todate][:month].to_i, params[:todate][:day].to_i))
        fcf.featured_author = fc
        fcf.save!

        flash[:notice] = I18n.t(:created_successfully)
        redirect_to url_for(action: :featured_author_show, id: fc.id)
      else
        flash[:error] = I18n.t(:no_such_item)
        redirect_to url_for(action: :index)
      end
    end
  end

  def featured_author_delete_feature
    fcf = FeaturedAuthorFeature.find(params[:id])
    unless fcf.nil?
      fcid = fcf.featured_author_id
      fcf.destroy!
      flash[:notice] = I18n.t(:deleted_successfully)
      redirect_to url_for(action: :featured_author_show, id: fcid)
    else
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :index)
    end
  end


  ########################################################
  # user content moderation
  def tag_moderation
    require_editor('moderate_tags')
    @header_partial = 'tagmod_top'
    if current_user.admin?
      status_to_query = [:pending, :escalated]
    else
      status_to_query = :pending
    end
    @pending_tags = Tag.includes(:taggings).where(status: status_to_query).distinct.order(:created_at)
    if params[:tag_id].present?
      @tag_id = params[:tag_id].to_i
      @tag = Tag.find(@tag_id)
      @pending_taggings = Tagging.joins(:tag).where(status: status_to_query, tag_id: @tag_id).where(tag: {status: :approved}).distinct.order(:created_at)
    else
      @pending_taggings = Tagging.joins(:tag).where(status: status_to_query).where(tag: {status: :approved}).distinct.order(:created_at)
    end
    @page_title = t(:moderate_tags)
    @similar_tags = ListItem.where(listkey: 'tag_similarity').pluck(:item_id, :extra).to_h
    calculate_editor_tagging_stats
    @dashboards = true
  end

  def tag_review
    require_editor('moderate_tags')
    @header_partial = 'tagmod_top'
    @tag = Tag.find(params[:id])
    if @tag.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :tag_moderation)
    else
      stags = ListItem.where(listkey: 'tag_similarity', item: @tag).pluck(:extra).map{|x| x.split(':')}.sort_by{|score, tag| score}.reverse
      @similar_tags = Tag.find(stags.map{|x| x[1]})
      calculate_editor_tagging_stats
      @next_tag_id = Tag.where(status: :pending).where('created_at > ?', @tag.created_at).order(:created_at).limit(1).pluck(:id).first
      @prev_tag_id = Tag.where(status: :pending).where('created_at < ?', @tag.created_at).order('created_at desc').limit(1).pluck(:id).first
    end
  end

  def tagging_review
    require_editor('moderate_tags')
    @header_partial = 'tagmod_top'
    @tagging = Tagging.find(params[:id])
    if @tagging.nil?
      flash[:error] = I18n.t(:no_such_item)
      redirect_to url_for(action: :tag_moderation)
    else
      @suggester_taggings_count = @tagging.suggester.taggings.count
      @suggester_acceptance_rate = @tagging.suggester.taggings.where(status: :approved).count.to_f / @suggester_taggings_count
      calculate_editor_tagging_stats
      @next_tagging_id = Tagging.where(status: :pending).where('created_at > ?', @tagging.created_at).order(:created_at).limit(1).pluck(:id).first
      @prev_tagging_id = Tagging.where(status: :pending).where('created_at < ?', @tagging.created_at).order('created_at desc').limit(1).pluck(:id).first
      if @tagging.taggable_type == 'Person'
        @author = Person.find(@tagging.taggable_id)
        unless @author.toc.nil?
          prep_toc
        else
          generate_toc
        end
      elsif @tagging.taggable_type == 'Manifestation'
        @m = Manifestation.find(@tagging.taggable_id)
        @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
      end
    end
  end

  def merge_tag
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tag.find(params[:id])
      if t.present?
        @tag = t
        if params[:with_tag].present?
          @with_tag = Tag.find(params[:with_tag].to_i)
        end
        render layout: false
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def do_merge_tag
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tag.find(params[:id])
      if t.present?
        if params[:with_tag].present?
          with_tag = Tag.find(params[:with_tag].to_i)
          if with_tag.present?
            t.merge_into(with_tag)
            Notifications.tag_merged(t.name, t.creator, with_tag.name).deliver unless t.creator.blocked? # don't send email if user is blocked
            flash[:notice] = t(:tag_merged)
          end
        elsif params[:tag].present?
          t.update(name: params[:tag], status: :approved)
          #Notifications.tag_renamed_and_approved(t.name, t.creator, params[:tag]).deliver unless t.creator.blocked? # don't send email if user is blocked
          Notifications.tag_rejected(t, params[:reason], params[:orig_tag_name]).deliver unless t.creator.blocked? # don't send email if user is blocked
        else
          flash[:error] = t(:no_such_item)
        end
      else
        flash[:error] = t(:no_such_item)
      end
    else
      flash[:error] = t(:tagging_system_locked)
    end
    redirect_to url_for(action: :tag_moderation)
  end

  def merge_tagging
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tagging.find(params[:id])
      if t.present?
        @tagging = t
        render layout: false
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def do_merge_tagging
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tagging.find(params[:id])
      if t.present?
        orig_name = t.tag.name
        with_tag = Tag.find(params[:with_tag].to_i)
        if with_tag.present?
          t.update(tag_id: with_tag.id, status: :approved)
          Notifications.tag_merged(t, orig_name, t.suggester).deliver unless t.suggester.blocked? # don't send email if user is blocked
          flash[:notice] = t(:tagging_merged)
        else
          flash[:error] = t(:no_such_item)
        end
      else
        flash[:error] = t(:no_such_item)
      end
    else
      flash[:error] = t(:tagging_system_locked)
    end
    redirect_to url_for(action: :tag_moderation)
  end
  
  def approve_tag # approve tag and proceed to review taggings
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tag.find(params[:id])
      if t.present?
        t.approve!(current_user)
        Notifications.tag_approved(t).deliver unless t.creator.blocked? # don't send email if user is blocked
        flash[:notice] = t(:tag_approved)
        redirect_to url_for(action: :tag_moderation, tag_id: t.id)
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def approve_tag_and_next # to be called from tag review page (non-AJAX)
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tag.find(params[:id])
      if t.present?
        t.approve!(current_user)
        Notifications.tag_approved(t).deliver unless t.creator.blocked? # don't send email if user is blocked
        next_items = Tag.where(status: :pending).where('created_at > ?', t.created_at).order(:created_at).limit(1)
        if next_items.first.present?
          redirect_to url_for(action: :tag_review, id: next_items.first.id)
        else
          flash[:notice] = t(:no_more_to_review)
          redirect_to url_for(action: :tag_moderation)
        end
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def reject_tag_and_next
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tag.find(params[:id])
      if t.present?
        t.reject!(current_user)
        #if params[:reason].present?
          Notifications.tag_rejected(t, params[:reason]).deliver unless t.creator.blocked? # don't send email if user is already blocked
        #end
        next_items = Tag.where(status: :pending).where('created_at > ?', t.created_at).order(:created_at).limit(1)
        if next_items.first.present?
          flash[:notice] = t(:tag_rejected)
          redirect_to url_for(action: :tag_review, id: next_items.first.id)
        else
          flash[:notice] = t(:no_more_to_review)
          redirect_to url_for(action: :tag_moderation)
        end
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end
  
  def reject_tag
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tag.find(params[:id])
      if t.present?
        t.reject!(current_user)
        #if params[:reason].present?
          Notifications.tag_rejected(t, params[:reason]).deliver unless t.creator.blocked? # don't send email if user is already blocked
        #end
        return render json: { tag_id: t.id, tag_name: t.name }
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def escalate_tag
    require_editor('moderate_tags')
    if session[:tagging_lock]
      @tag = Tag.find(params[:id])
      if @tag.present?
        @tag.escalate!(current_user)
        respond_to do |format|
          format.html {
            next_items = Tag.where(status: :pending).where('created_at > ?', @tag.created_at).order(:created_at).limit(1)
            if next_items.first.present?
              flash[:notice] = t(:tag_escalated)
              redirect_to url_for(action: :tag_review, id: next_items.first.id)
            else
              flash[:notice] = t(:no_more_to_review)
              redirect_to url_for(action: :tag_moderation)
            end
          }
          format.js
        end
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def escalate_tagging
    require_editor('moderate_tags')
    if session[:tagging_lock]
      @tagging = Tagging.find(params[:id])
      if @tagging.present?
        @tagging.escalate!(current_user)
        respond_to do |format|
          format.html { redirect_to_next_tagging(@tagging, I18n.t(:tagging_escalated)) }
          format.js
          format.json { head :ok }
        end
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def approve_tagging
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tagging.find(params[:id])
      if t.present?
        t.approve!(current_user)
        Notifications.tagging_approved(t).deliver unless t.suggester.blocked? # don't send email if user is blocked
        respond_to do |format|
          format.html { redirect_to_next_tagging(t, I18n.t(:tagging_approved)) }
          format.json { head :ok }
        end
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end
  
  def reject_tagging
    require_editor('moderate_tags')
    if session[:tagging_lock]
      t = Tagging.find(params[:id])
      if t.present?
        t.reject!(current_user)
        Notifications.tagging_rejected(t, params[:explanation]).deliver unless t.suggester.blocked? # don't send email if user is blocked
        respond_to do |format|
          format.html { redirect_to_next_tagging(t, I18n.t(:tagging_rejected)) }
          format.json { head :ok }
        end
      else
        head :not_found
      end
    else
      head :forbidden
    end
  end

  def warn_user
    require_editor('moderate_tags') # TODO: update to a more generic editor bit
    u = User.find(params[:id])
    if u.present?
      u.warn!(params[:reason])
      flash[:notice] = t(:user_warned)
      url = params[:return_url] || url_for(action: :tag_moderation)
      redirect_to url
    else
      head :not_found
    end
  end

  def block_user
    require_editor('moderate_tags') # TODO: update to a more generic editor bit
    u = User.find(params[:id])
    if u.present?
      u.block!('tags', current_user, params[:reason])

      flash[:notice] = t(:user_blocked)
      url = params[:return_url] || url_for(action: :tag_moderation)
      redirect_to url
    else
      head :not_found
    end
  end

  def confirm_with_comment
    render partial: 'shared/confirm_with_comment', locals: {p1: params['p1'], with_comment: params['with_comment'], title: params['title'], element_id: params['element_id']}
  end

  private

  def vp_params
    params[:volunteer_profile].permit(:name, :bio, :about, :profile_image)
  end
  def fa_params
    params[:featured_author].permit(:title, :body)
  end
  def fc_params
    params[:featured_content].permit(:title, :body, :external_link)
  end
  def sp_params
    params[:static_page].permit(:tag, :title, :body, :status, :mode, :ltr)
  end
  def sn_params
    params[:sitenotice].permit(:body, :status)
  end
  def obtain_tagging_lock
    if File.exist?(TAGGING_LOCK)
      mtime = File.mtime(TAGGING_LOCK)
      if mtime.to_i < TAGGING_LOCK_TIMEOUT.minutes.ago.to_i
        File.open(TAGGING_LOCK, 'w') {|f| f.write("#{current_user.id}")}
        session[:tagging_lock] = true
      else
        lock_owner = File.open(TAGGING_LOCK).read.to_i
        if lock_owner == current_user.id
          FileUtils.touch(TAGGING_LOCK) # refresh the lock
          session[:tagging_lock] = true
        else
          @tagging_lock_owner = User.find(lock_owner).name
          @tagging_lock_refreshed = ((Time.current - mtime) / 60).floor
          session[:tagging_lock] = false
        end
      end
    else
      File.open(TAGGING_LOCK, 'w') {|f| f.write("#{current_user.id}")}
      session[:tagging_lock] = true
    end
    return true
  end
  def calculate_editor_tagging_stats
    @tags_done = Tag.where(approver_id: current_user.id).where.not(status: :pending).count
    @next_tags_milestone = PROGRESS_SERIES.find { |element| element > @tags_done }
    @tags_progress = (@tags_done) * 100 / @next_tags_milestone
    @taggings_done = Tagging.where(approved_by: current_user.id).where.not(status: :pending).count
    @next_taggings_milestone = PROGRESS_SERIES.find { |element| element > @taggings_done }
    @taggings_progress = (@taggings_done) * 100 / @next_taggings_milestone
  end
  def redirect_to_next_tagging(t, msg)
    @next_tagging_id = Tagging.where(status: :pending).where('created_at > ?', t.created_at).order(:created_at).limit(1).pluck(:id).first
    redirect_to(@next_tagging_id.present? ? url_for(tagging_review_path(@next_tagging_id)) : url_for(action: :tag_moderation), notice: msg)
  end

end
