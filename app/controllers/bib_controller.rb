include BybeUtils

class BibController < ApplicationController
  before_action {|c| c.require_editor('bib_workshop')}

  def index
    @counts = {pubs: Publication.count, holdings: Holding.count , obtained: Publication.where(status: Publication.statuses[:obtained]).count , scanned: Publication.where(status: Publication.statuses[:scanned]).count, copyrighted: Publication.where(status: Publication.statuses[:copyrighted]).count, uploaded: Publication.where(status: Publication.statuses[:uploaded]).count, irrelevant: Publication.where(status: Publication.statuses[:irrelevant]).count, missing: Holding.where(status: Holding.statuses[:missing]).count, authors_done: Person.has_toc.bib_done.count, authors_todo: Person.has_toc.count - Person.has_toc.bib_done.count}
    @digipubs = Publication.includes(holdings: :bib_source).where(status: Publication.statuses[:scanned]).order('rand()').limit(25)
    pid = params[:person_id]
    unless pid.nil?
      @person_id = pid.to_i
      @person_name = Person.find(@person_id).name.split(' ')[-1]
    end
    prepare_pubs
  end

  def publication_mark_false_positive
    pub = Publication.find(params[:id])
    li = ListItem.new(listkey: 'pubs_false_maybe_done', item: pub)
    li.save!
    li = ListItem.where(listkey: 'pubs_maybe_done', item: pub)
    unless li.empty?
      li.each {|item| item.destroy}
    end
    render js: "$('.pub#{pub.id}').remove();"
  end
  def scans
    @digipubs = Publication.includes(holdings: :bib_source).where(status: Publication.statuses[:scanned]).order('updated_at asc')
  end

  def make_author_page
    @p = Person.find(params[:person_id])
    if @p.nil?
      respond_to do |format|
        format.html { redirect_to action: :index }
        format.js { render :nothing }
      end
    else
      @pubs = @p.publications
      gen_toc = ''
      # make TOC
      @pubs.each do |pub|
        gen_toc += "### #{pub.title}\n#{pub.publisher_line}, #{pub.pub_year} \n\n"
      end
      gen_toc = gen_toc.gsub(' :',':').gsub(' ;',';')
      # save TOC to person if no TOC yet
      if @p.toc.nil?
        t = Toc.new(toc: gen_toc,  credit_section: "## #{I18n.t(:typed)}\n* ...\n\n## #{I18n.t(:proofed)}\n* ...", status: :raw)
        t.save!
        @p.toc = t
        @p.save!
      else
        @gen_toc = gen_toc # set @gen_toc for edit_toc to show
      end
      # present TOC if person already has manual TOC
      flash[:notice] = t(:created_toc)
      @author = @p
      prep_toc
      render 'authors/edit_toc'
    end
  end

  def person
    @p = Person.find(params[:person_id])
    if @p.nil?
      respond_to do |format|
        format.html { redirect_to action: :index }
        format.js { render :nothing }
      end
    else
      @pubs = @p.publications.order(:status)
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  def pubs_by_person
    prepare_pubs
    q = params['q']
    @person_id = params[:person_id]
    unless @person_id.nil? || @person_id.empty?
      @person = Person.find(@person_id)
    end
    @total_pubs = '0'
    unless q.nil? or q.empty?
      @pubs = []

      sources = []
      if params['bib_source'] == 'all'
        sources = BibSource.enabled
      else
        sources << BibSource.find(params['bib_source'])
      end
      sources.each do |bib_source|
        @pubs += query_source_by_type(q, bib_source).select  {|pub| Holding.where(source_id: url_for_record(bib_source, (pub.source_id.class == Array ? pub.source_id[0] : pub.source_id))).empty? }
      end
      @total_pubs = @pubs.count.to_s
    end
  end

  def make_scanning_task
    pub = Publication.find(params[:id])
    if pub.nil?
      render plain: 'moose'
    else
      Net::HTTP.start(AppConstants.tasks_system_host, AppConstants.tasks_system_port, :use_ssl => AppConstants.tasks_system_port == 443 ? true : false) do |http|
        req = Net::HTTP::Post.new('/api/create_task')
        req.set_form_data(title: pub.title, author: pub.author_line, 
          edition_details: "#{pub.publisher_line}, #{pub.pub_year}", extra_info: "#{pub.language}\n#{pub.notes}",
          api_key: current_user.tasks_api_key)
        task_result = JSON.parse(http.request(req).body)
        logger.debug("task_result: #{task_result.to_s}")
        if task_result['task'].present?
          pub.status = 'scanned'
          pub.task_id = task_result['task']['id']
          pub.save!
          portpart = AppConstants.tasks_system_port == 80 ? '' : ":#{AppConstants.tasks_system_port }"
          taskurl = "#{AppConstants.tasks_system_port == 443 ? 'https://' : 'http://'}#{AppConstants.tasks_system_host}#{portpart}/tasks/#{task_result['task']['id']}"
          render inline: taskurl
        else
          render inline: 'alert("אירעה שגיאה ביצירת המשימה.");'
        end
      end
    end
  end

  def todo_by_location
    loc = params['location']
    Holding.where(status: Holding.statuses[:todo])
  end

  def pubs_maybe_done
    @pubs = []
    ListItem.includes(:item).where(listkey: 'pubs_maybe_done').each do |pub|
      item = pub.item
      mm = Manifestation.where("title like ?", pub_title_for_comparison(item.title)+'%')
      @pubs << [item, mm]
    end
  end
  def shopping
    hh = []
    case
    when params[:pd] == '1' && params[:unique] == '1'
      pp = Publication.joins(:holdings, :person).group('publications.id').having('COUNT(distinct holdings.bib_source_id) = 1').where("publications.status = 'todo' and people.public_domain = 1 and holdings.bib_source_id = #{params[:source_id]}") # get all publications available in only one source
      pp.each{|p| p.holdings.each {|h| hh << h }}
    when params[:pd] == '1' && (params[:unique].nil? || params[:unique] == '0')
      hh = Holding.to_obtain(params[:source_id]).joins(publication: [:person]).includes(publication: :holdings).where('people.public_domain' => true).to_a
    when (params[:pd].nil? || params[:pd] == '0') && params[:unique] == '1'
      pp = Publication.joins(:holdings).group('publications.id').having('COUNT(distinct holdings.bib_source_id) = 1').where('publications.status = "todo"') # get all publications available in only one source
      pp.each{|p| p.holdings.each {|h| hh << h if h.bib_source_id == params[:source_id].to_i}}
    when params[:nonpd] == '1' && params[:unique] == '1'
      pp = Publication.joins(:holdings, :person).group('publications.id').having('COUNT(distinct holdings.bib_source_id) = 1').where('publications.status = "todo" and people.public_domain = 0') # get all publications available in only one source
      pp.each{|p| p.holdings.each {|h| hh << h if h.bib_source_id == params[:source_id].to_i}}
    when params[:nonpd] == '1' && (params[:unique].nil? || params[:unique] == '0')
      hh = Holding.to_obtain(params[:source_id]).joins(publication: [:person]).includes(publication: :holdings).where('people.public_domain' => false).to_a
    else
        hh = Holding.to_obtain(params[:source_id]).to_a
    end

    @holdings = hh.sort_by!{|h|
      loc = h.location || ''
      s = loc.sub(/\(.*\)/,'').tr('[א-ת]','')
      pos = s.index('.') || -1
      s[0..pos]
    }
    @source = BibSource.find(params[:source_id])
  end

  def holding_status
    @holding = Holding.find(params[:id])
    pub = @holding.publication
    @holding.status = params[:status]
    @holding.save!
    if pub.status == 'todo' and ['scanned', 'obtained'].include?(params[:status])
      pub.status = params[:status]
      pub.save!
    end
    @the_id = case params[:status]
      when 'obtained'
        "obt#{@holding.id}"
      when 'scanned'
        "scn#{@holding.id}"
      when 'missing'
        "msng#{@holding.id}"
      end
  end

  private

  def prepare_pubs
    @select_options = BibSource.enabled.map{|tn| [tn.title, tn.id]}.unshift([I18n.t(:all_sources),:all])
  end

  def query_source_by_type(q, bib_source)
    case bib_source.source_type
    when 'aleph'
      provider = Gared::Aleph.new(bib_source.url, bib_source.port, bib_source.institution)
    when 'googlebooks'
      provider = Gared::Googlebooks.new(bib_source.api_key)
    when 'hebrewbooks'
      provider = Gared::Hebrewbooks.new
    when 'primo'
      provider = Gared::Primo.new(bib_source.url, bib_source.institution)
    when 'idea'
      provider = Gared::Idea.new(bib_source.url)
    when 'nli_api'
      provider = Gared::Nli_Api.new(bib_source.url, bib_source.api_key)
    end
    ret = []
    ret = provider.query_publications_by_person(q, bib_source) if provider # bib_source is sent as context, so that the resulting Publication objects would be able to access the linkify logic for their source; should probably be replaced by a proc
    return ret
  end
end
