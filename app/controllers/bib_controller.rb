include BybeUtils

class BibController < ApplicationController
  before_action {|c| c.require_editor('bib_workshop')}

  def index
    @counts = {pubs: Publication.count, holdings: Holding.count , obtained: Publication.where(status: Publication.statuses[:obtained]).count , scanned: Publication.where(status: Publication.statuses[:scanned]).count, uploaded: Publication.where(status: Publication.statuses[:uploaded]).count, irrelevant: Publication.where(status: Publication.statuses[:irrelevant]).count, missing: Holding.where(status: Holding.statuses[:missing]).count, authors_done: Person.has_toc.bib_done.count, authors_todo: Person.has_toc.count - Person.has_toc.bib_done.count}
    @digipubs = Publication.where(status: Publication.statuses[:scanned]).order('rand()').limit(25)
    pid = params[:person_id]
    unless pid.nil?
      @person_id = pid.to_i
      @person_name = Person.find(@person_id).name.split(' ')[-1]
    end
    prepare_pubs

  end

  def scans
    @digipubs = Publication.where(status: Publication.statuses[:scanned]).order('updated_at asc')
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
      gen_toc.gsub!(' :',':').gsub!(' ;',';')
      # save TOC to person if no TOC yet
      if @p.toc.nil?
        t = Toc.new(toc: gen_toc, status: :raw)
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
    unless q.nil? or q.empty?
      @pubs = []

      sources = []
      if params['bib_source'] == 'all'
        sources = BibSource.enabled
      else
        sources << BibSource.find(params['bib_source'])
      end
      sources.each do |bib_source|
#        recs = query_source_by_type(q, bib_source)
#        to_add = []
#        recs.each do |pub|
#          sid = (pub.source_id.class == Array ? pub.source_id[0] : pub.source_id)
#          yesno = Holding.where(source_id: url_for_record(bib_source, sid)).empty?
#          to_add << pub if yesno
#        end
#        @pubs += to_add
        @pubs += query_source_by_type(q, bib_source).select  {|pub| Holding.where(source_id: url_for_record(bib_source, (pub.source_id.class == Array ? pub.source_id[0] : pub.source_id))).empty? }
      end
    end
  end

  def todo_by_location
    loc = params['location']
    Holding.where(status: Holding.statuses[:todo])
  end

  def shopping
    hh = Holding.to_obtain(params[:source_id]).to_a
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
    end
    ret = []
    ret = provider.query_publications_by_person(q, bib_source) if provider # bib_source is sent as context, so that the resulting Publication objects would be able to access the linkify logic for their source; should probably be replaced by a proc
    return ret
  end
end
