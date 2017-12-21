class AdminController < ApplicationController
  before_filter :require_editor
  before_filter :require_admin, only: [:missing_languages, :missing_genres, :incongruous_copyright]
  autocomplete :manifestation, :title, display_value: :title_and_authors
  autocomplete :person, :name

  def index
    if current_user && current_user.editor?
      @open_proofs = Proof.where(status: 'new').count.to_s
      @open_recommendations = LegacyRecommendation.where(status: 'new').count.to_s
      @page_title = t(:dashboard)
    end
  end

  ##############################################
  ## Reports
  def raw_tocs
    @authors = Person.joins(:toc).where('tocs.status = 0').page(params[:page]).per(15)
    @total = Person.joins(:toc).where('tocs.status = 0').count
  end

  def missing_languages
    ex = Expression.joins([:realizers, :works]).where(realizers: {role: Realizer.roles[:translator]}, works: {orig_lang: 'he'})
    mans = ex.map{|e| e.manifestations[0]}
    @mans = Kaminari.paginate_array(mans).page(params[:page]).per(25)
  end

  def missing_genres
    @mans = Manifestation.joins(:expressions).where(expressions: {genre: nil}).page(params[:page]).per(25)
  end

  def missing_copyright
    @authors = Person.where(public_domain: nil)
    @mans = Manifestation.joins(:expressions).where(expressions: {copyrighted: nil}).page(params[:page]).per(25)
  end

  def suspicious_translations # find works where the author is also a translator -- this *may* be okay, in the case of self-translation, but probably is a mistake
    @mans = Manifestation.joins(expressions: [:realizers, works: [:creations]]).where('realizers.person_id = creations.person_id and realizers.role = 3').page(params[:page])
  end

  def conversion_verification
    @manifestations = Manifestation.where(conversion_verified: false).order(:title).page(params[:page])
    @total = Manifestation.where(conversion_verified: false).count
  end

  def translated_from_multiple_languages
    @authors = []
    translatees = Person.joins(creations: :work).includes(:works).where('works.orig_lang <> "he"').distinct
    translatees.each {|t|
      if t.works.pluck(:orig_lang).uniq.count > 1
        works_by_lang = {}
        t.works.each { |w|
          works_by_lang[w.orig_lang] = [] if works_by_lang[w.orig_lang].nil?
          works_by_lang[w.orig_lang] << w
        }
        @authors << [t, t.works.pluck(:orig_lang).uniq, works_by_lang]
      end
    }
  end

  def incongruous_copyright
    # Manifestation.joins([expressions: [[realizers: :person],:works]]).where(expressions: {copyrighted:true},people: {public_domain:true})
    @incong = []
    Manifestation.all.each {|m|
      calculated_copyright = m.expressions[0].should_be_copyrighted?
      db_copyright = m.expressions[0].copyrighted
      if calculated_copyright != db_copyright
        @incong << [m, m.title, m.author_string, calculated_copyright, db_copyright]
      end
    }
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
    @vp = VolunteerProfile.new(params[:volunteer_profile])
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
      if @vp.update_attributes(params[:volunteer_profile])
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
    @fc = FeaturedContent.new(params[:featured_content])
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
      if @fc.update_attributes(params[:featured_content])
        flash[:notice] = I18n.t(:updated_successfully)
        redirect_to action: :featured_content_show, id: @fc.id
      else
        format.html { render action: 'featured_content_edit' }
        format.json { render json: @fc.errors, status: :unprocessable_entity }
      end
    end
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
    @fc = FeaturedAuthor.new(params[:featured_author])
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
      if @fc.update_attributes(params[:featured_author])
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

end
