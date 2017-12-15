require 'pandoc-ruby' # for generic DOCX-to-HTML conversions

class HtmlFileController < ApplicationController
  before_filter :require_editor, only: [:edit, :update, :list_for_editor]
  # before_filter :require_user, :only => [:edit, :update]

  before_filter :require_admin, only: [:analyze, :analyze_all, :new, :create, :list, :parse, :publish, :unsplit, :chop1, :chop2, :chop3, :choplast1, :choplast2, :poetry, :frbrize]

  def analyze
    @text = HtmlFile.find(params[:id])
    @text.analyze
    params['status'] = 'Analyzed'
    params['commit'] = 'Commit'
    list
    render action: :list # help user find the newly-analyzed files
  end

  def new
    @text = HtmlFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @text }
    end
  end

  def create
    @text = HtmlFile.new(params[:html_file])
    respond_to do |format|
      if @text.save
        format.html { redirect_to url_for(action: :edit_markdown, id: @text.id), notice: t(:updated_successfully) }
        format.json { render json: @text, status: :created, location: @text }
      else
        format.html { render action: "new" }
        format.json { render json: @text.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_markdown
    @text = HtmlFile.find(params[:id])
    unless params[:markdown].nil?
      @text.markdown = params[:markdown].gsub('__________', '__SPLIT__') # TODO: make secure
      @text.genre = params[:genre] unless params[:genre].blank?
      @text.comments = params[:comments]
      @text.save
    end

    if @text.markdown.nil? # convert on first show
      bin = Faraday.get @text.doc.url # grab the doc/x binary
      tmpfile = Tempfile.new(['docx2mmd__','.docx'], :encoding => 'ascii-8bit')
      begin
        tmpfile.write(bin.body)
        tmpfilename = tmpfile.path
        markdown = `pandoc -f docx -t markdown_mmd #{tmpfilename}`
        @text.markdown = markdown
        @text.save
      rescue
        flash[:error] = t(:conversion_error)
        redirect_to controller: :admin, action: :index
      ensure
        tmpfile.close
      end
    end
    @markdown = @text.markdown
    @html = MultiMarkdown.new(@markdown.gsub('__SPLIT__', '__________')).to_html.force_encoding('UTF-8') # TODO: figure out why to_html defaults to ASCII 8-bit
  end

  def edit
    @text = HtmlFile.find(params[:id])
  end

  def update
    @text = HtmlFile.find(params[:id])
    @text.year_published = params[:year_published]
    @text.orig_year_published = params[:orig_year_published]
    @text.orig_lang = params[:orig_lang]
    @text.orig_author = params[:orig_author]
    @text.orig_author_url = params[:orig_author_url]
    @text.genre = params[:genre]
    @text.comments = params[:comments]
    if @text.save
      flash[:notice] = 'הנתונים עודכנו!'
    else
      flash[:error] = 'אירעה שגיאה.  הנתונים לא נשמרו.  סליחה.'
    end
    redirect_to action: :list_for_editor
  end

  def analyze_all
    # TODO: implement, but only with some safety -- this can take a while!
  end

  def list_for_editor
    if params[:path].blank?
      @dirs = HtmlDir.all
    else
      @author = params[:author]
      @texts = HtmlFile.where('path like ?', '%/' + params[:path] + '/%').order('seqno ASC').page(params[:page])
    end
  end

  def list
    # calculate tallies
    @total_texts = HtmlFile.count
    @total_known = HtmlFile.where.not(status: 'Unknown').count
    @total_images = HtmlFile.where(images: true).count
    @total_footnotes = HtmlFile.where(footnotes: true).count
    @total_tables = HtmlFile.where(tables: true).count
    @total_badenc = HtmlFile.where(status: 'BadCP1255').count
    @total_fileerr = HtmlFile.where(status: 'FileError').count
    @total_parsed = HtmlFile.where(status: 'Parsed').count
    @total_accepted = HtmlFile.where(status: 'Accepted').count
    @total_published = HtmlFile.where(status: 'Published').count
    @total_manual = HtmlFile.where(status: 'Manual').count
    @total_nikkud_full = HtmlFile.where(nikkud: 'full').count
    @total_nikkud_some = HtmlFile.where(nikkud: 'some').count
    @total_assigned = HtmlFile.where("assignee_id is not null and status != 'Published'").count
    # build query condition
    query = {}
    unless params[:commit].blank?
      session[:html_q_params] = params # make prev. params accessible to view
    else
      session[:html_q_params] = { footnotes: '', nikkud: '', status: params['status'], path: '' }
    end
    f = session[:html_q_params][:footnotes]
    n = session[:html_q_params][:nikkud]
    s = params[:status] or session[:html_q_params][:status]
    p = session[:html_q_params][:path] # retrieve query params whether or not they were POSTed
    query.merge!(footnotes: f) unless f.blank?
    query.merge!(nikkud: n) unless n.blank?
    query.merge!(status: s) unless s.blank?
    assignee_cond = "assignee_id is null or assignee_id = #{current_user.id}"

    # TODO: figure out how to include filter by path without making the query fugly
    if p.blank?
      @texts = HtmlFile.where(assignee_cond).where(query).page(params[:page]).order('status ASC')
    else
      @texts = HtmlFile.where(assignee_cond).where('path like ?', '%' + params[:path] + '%').page(params[:page]).order('status ASC')
    end
    # @texts = HtmlFile.page(params[:page]).order('status ASC')
  end

  def parse
    @text = HtmlFile.find(params[:id])
    if @text.assignee.blank? or @text.assignee = current_user
      @text.assign(current_user.id)
      @text.parse
      redirect_to url_for(action: :render_html, id: @text.id)
    else
      redirect_to url_for(action: :list) # help user find the newly-parsed files
    end
  end

  def mark_manual
    @text = HtmlFile.find(params[:id])
    @text.status = 'Manual'
    @text.assignee_id = nil
    @text.save!
    redirect_to action: :list
  end

  def frbrize
    @text = HtmlFile.find(params[:id])
    if @text.genre.blank?
      flash[:error] = t(:must_set_genre)
      redirect_to action: :render_html, id: @text.id
    else
      unless @text.person.nil?
        @text.status = 'Accepted'
        @text.genre = params['genre'] unless params['genre'].nil?
        @text.save!
        @text.create_WEM(@text.person.id)
        flash[:notice] = t(:created_frbr)
        redirect_to action: :list
      else
        flash[:error] = t(:cannot_create_frbr)
        redirect_to action: :render_html, id: @text.id
      end
    end
  end

  def publish
    @text = HtmlFile.find(params[:id])
    if @text.status == 'Accepted'
      @text.make_html unless @text.html_ready?
      if @text.metadata_ready?
        @text.publish
        flash[:notice] = t(:html_file_published)
      else
        flash[:error] = 'Metadata not ready yet!'
      end
    else
      flash[:error] = t(:must_accept_before_publishing)
    end
    redirect_to url_for(action: :list, status: 'Parsed') # help user find the newly-parsed files

  end

  def unsplit
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read
    @markdown.gsub!('__SPLIT__', '') # remove magic words
    @text.update_markdown(@markdown)
    redirect_to action: :render_html, id: params[:id]
  end

  def render_by_legacy_url
    if params[:format] && params[:format] == 'xml'
      head :bad_request
    else
      the_url = params[:path] + '.html'
      the_url = '/' + the_url if the_url[0] != '/' # prepend slash if necessary
      h = HtmlFile.find_by_url(the_url)
      unless h.nil?
        # TODO: handle errors, at least path not found
        if h.status != 'Published'
          @html = File.open(h.path, 'r:UTF-8').read
        else
          redirect_to url_for(controller: :manifestation, action: :read, id: h.manifestations[0].id)
        end
      else
        @html = '<h1>bad path</h1>'
      end
    end
  end

  def render_html
    pp = params.permit(:id, :markdown, :genre, :add_person, :role, :comments, :remove_line_nums)
    @text = HtmlFile.find(pp[:id])
    if pp[:markdown].nil?
      @markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read
    else
      @markdown = pp[:markdown] # TODO: make secure
      @text.update_markdown(@markdown.gsub('__________', '__SPLIT__')) # TODO: add locking of some sort to avoid concurrent overwrites
      @text.delete_pregen
      @text.genre = pp[:genre] unless pp[:genre].blank?
      @text.comments = pp[:comments]
      @markdown = @text.remove_line_nums! unless pp[:remove_line_nums].blank?
      unless pp[:add_person].blank?
        if pp[:role].to_i == HtmlFile::ROLE_AUTHOR
          @text.set_orig_author(pp[:add_person].to_i)
        else # translator
          @text.set_translator(pp[:add_person].to_i)
        end
      end
      @text.save
    end
    @html = MultiMarkdown.new(@markdown.gsub('__SPLIT__', '__________')).to_html.force_encoding('UTF-8') # TODO: figure out why to_html defaults to ASCII 8-bit
    @person_matches = match_person(@text.author_string)
  end

  def poetry
    @text = HtmlFile.find(params[:id])
    @text.paras_to_lines!
    @text.paras_condensed = true # running it again would lose stanzas!
    @text.save!
    redirect_to action: :render_html, id: params[:id]
  end

  def chop_title
    @text = HtmlFile.find(params[:id])
    markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read # need to read the whole thing, to save it back
    lines = markdown.split "\n"
    title = lines.shift
    new_title = lines.shift while new_title !~ /\p{Word}/
    slashpos = new_title.index('/')
    slashpos = 0 if slashpos.nil?
    updated_title = new_title[0..slashpos-1].strip
    unless slashpos.nil?
      title =~ /\//
      newbuf = '# '+updated_title+' /'
      if $'.nil?
        newbuf += ' '+@text.html_dir.person.name
      else
        newbuf += $'
      end
      newbuf += "\n"+lines.join("\n")
      File.open(@text.path + '.markdown', 'wb') {|f| f.write(newbuf)} # write back
      flash[:notice] = t(:updated_successfully)
    else
      flash[:error] = t(:malformed_line)
    end
    redirect_to action: :render_html, id: params[:id]
  end

  def chop3
    chopN(3)
    redirect_to action: :render_html, id: params[:id]
  end

  def chop2
    chopN(2)
    redirect_to action: :render_html, id: params[:id]
  end

  def chop1
    chopN(1)
    redirect_to action: :render_html, id: params[:id]
  end

  def choplast1
    choplastN(1)
    redirect_to action: :render_html, id: params[:id]
  end

  def choplast2
    choplastN(2)
    redirect_to action: :render_html, id: params[:id]
  end

  def metadata
    @text = HtmlFile.find(params[:id])
    @authors = @text.guess_authors
  end
  def confirm_html_dir_person
    @text = HtmlFile.find(params[:id])
    @text.person = @text.html_dir.person
    @text.save!
    flash[:notice] = t(:confirmed_person_as_author, author: @text.person.name)
    render json: nil
  end
  protected

  def render_from_markdown(htmlfile)
    markdown = File.open(htmlfile.path + '.markdown', 'r:UTF-8').read
    html = MultiMarkdown.new(markdown.gsub('__SPLIT__', '__________')).to_html.force_encoding('UTF-8') # TODO: figure out why to_html defaults to ASCII 8-bit
    html
  end
  def choplastN(line_count)
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read
    File.open(@text.path + '.markdown', 'wb') {|f| f.write(@markdown.split("\n")[0..-(line_count+1)].join("\n"))}
  end
  def chopN(line_count) # TODO: rewrite this weird mess
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read
    lines = @markdown.split "\n"
    new_lines = []
    if lines[0] =~ /^#\s+/
      new_lines.push lines[0] # copy over our own generated title / author line
      lines.shift
    end
    while line_count > 0
      line = lines.shift
      if line.match /\S/
        line_count -= 1 # skip one non-empty line and decrement
      else
        new_lines.push line # preserve whitespace lines
      end
      next
    end
    new_lines += lines # just append the remaining lines
    @markdown = new_lines.join "\n"
    File.open(@text.path + '.markdown', 'wb') { |f| f.write(@markdown) } # write back
  end
end
