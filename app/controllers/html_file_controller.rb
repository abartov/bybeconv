class HtmlFileController < ApplicationController
  before_filter :require_editor, only: [:edit, :update, :list_for_editor]
  # before_filter :require_user, :only => [:edit, :update]

  before_filter :require_admin, only: [:analyze, :analyze_all, :list, :parse, :publish, :unsplit, :chop1, :chop2, :chop3, :poetry]

  def analyze
    @text = HtmlFile.find(params[:id])
    @text.analyze
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
    @total_known = HtmlFile.count(conditions: "status <> 'Unknown'")
    @total_images = HtmlFile.count(conditions: 'images = 1')
    @total_footnotes = HtmlFile.count(conditions: 'footnotes = 1')
    @total_tables = HtmlFile.count(conditions: 'tables = 1')
    @total_badenc = HtmlFile.count(conditions: "status = 'BadCP1255'")
    @total_fileerr = HtmlFile.count(conditions: "status = 'FileError'")
    @total_parsed = HtmlFile.count(conditions: "status = 'Parsed'")
    @total_accepted = HtmlFile.count(conditions: "status = 'Accepted'")
    @total_nikkud_full = HtmlFile.count(conditions: "nikkud = 'full'")
    @total_nikkud_some = HtmlFile.count(conditions: "nikkud = 'some'")
    # build query condition
    query = {}
    unless params[:commit].blank?
      session[:html_q_params] = params # make prev. params accessible to view
    else
      session[:html_q_params] = { footnotes: '', nikkud: '', status: '', path: '' }
    end
    f = session[:html_q_params][:footnotes]
    n = session[:html_q_params][:nikkud]
    s = session[:html_q_params][:status]
    p = session[:html_q_params][:path] # retrieve query params whether or not they were POSTed
    query.merge!(footnotes: f) unless f.blank?
    query.merge!(nikkud: n) unless n.blank?
    query.merge!(status: s) unless s.blank?
    # TODO: figure out how to include filter by path without making the query fugly
    if p.blank?
      @texts = HtmlFile.where(query).page(params[:page]).order('status ASC')
    else
      @texts = HtmlFile.where('path like ?', '%' + params[:path] + '%').page(params[:page]).order('status ASC')
    end
    # @texts = HtmlFile.page(params[:page]).order('status ASC')
  end

  def parse
    @text = HtmlFile.find(params[:id])
    @text.parse
  end

  def publish
    @text = HtmlFile.find(params[:id])
    @text.make_html unless @text.html_ready?
    if @text.metadata_ready?
      @text.publish
      flash[:notice] = 'Published!'
    else
      flash[:error] = 'Metadata not ready yet!'
    end
    redirect_to action: :list
  end

  def unsplit
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read
    @markdown.gsub!('__SPLIT__', '') # remove magic words
    @text.update_markdown(@markdown)
    redirect_to action: :render_html, id: params[:id]
  end

  def render_by_legacy_url
    the_url = params[:path] + '.html'
    the_url = '/' + the_url if the_url[0] != '/' # prepend slash if necessary
    h = HtmlFile.find_by_url(the_url)
    unless h.nil?
      # TODO: handle errors, at least path not found
      if h.status != 'Published'
        @html = '<h1>not yet.</h1>'
        # @html = "<h1>יצירה זו אינה מוכנה עדיין.</h1>"
      else
        h.make_html unless h.html_ready?
        @html = File.open(h.path + '.html', 'r').read
      end
    else
      @html = '<h1>bad path</h1>'
      # @html = "<h1>כתובת הדף אינה תקינה</h1>"
    end
  end

  def render_html
    @text = HtmlFile.find(params[:id])
    if params[:markdown].nil?
      @markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read
    else
      @markdown = params[:markdown] # TODO: make secure
      @text.update_markdown(@markdown.gsub('__________', '__SPLIT__')) # TODO: add locking of some sort to avoid concurrent overwrites
      @text.delete_pregen
    end
    @html = MultiMarkdown.new(@markdown.gsub('__SPLIT__', '__________')).to_html.force_encoding('UTF-8') # TODO: figure out why to_html defaults to ASCII 8-bit
  end

  def poetry
    @text = HtmlFile.find(params[:id])
    @text.paras_to_lines!
    @text.save!
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

  def metadata
    @text = HtmlFile.find(params[:id])
    @authors = @text.guess_authors
  end

  protected

  def render_from_markdown(htmlfile)
    markdown = File.open(htmlfile.path + '.markdown', 'r:UTF-8').read
    html = MultiMarkdown.new(markdown.gsub('__SPLIT__', '__________')).to_html.force_encoding('UTF-8') # TODO: figure out why to_html defaults to ASCII 8-bit
    html
  end

  def chopN(line_count)
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path + '.markdown', 'r:UTF-8').read
    lines = @markdown.split "\n"
    new_lines = []
    while line_count > 0
      line = lines.shift
      if line.match /\S/ and !line.match /#\s+\S+/ # ignore our own generated title / author line
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
