class HtmlFileController < ApplicationController
  def analyze
    @text = HtmlFile.find(params[:id])
    @text.analyze
  end

  def analyze_all
  end

  def list
    # calculate tallies
    @total_texts = HtmlFile.count
    @total_known = HtmlFile.count(:conditions => "status <> 'Unknown'")
    @total_images = HtmlFile.count(:conditions => "images = 't'")
    @total_footnotes = HtmlFile.count(:conditions => "footnotes = 't'")
    @total_tables = HtmlFile.count(:conditions => "tables = 't'")
    @total_badenc = HtmlFile.count(:conditions => "status = 'BadCP1255'")
    @total_fileerr = HtmlFile.count(:conditions => "status = 'FileError'")
    @total_parsed = HtmlFile.count(:conditions => "status = 'Parsed'")
    @total_accepted = HtmlFile.count(:conditions => "status = 'Accepted'")
    @total_nikkud_full = HtmlFile.count(:conditions => "nikkud = 'full'")
    @total_nikkud_some = HtmlFile.count(:conditions => "nikkud = 'some'")
    # build query condition
    query = {}
    unless params[:commit].blank?
      session[:html_q_params] = params # make prev. params accessible to view
    else
      session[:html_q_params] = { :footnotes => '', :nikkud => '', :status => '', :path => '' }
    end
    f, n, s, p = session[:html_q_params][:footnotes], session[:html_q_params][:nikkud], session[:html_q_params][:status], session[:html_q_params][:path] # retrieve query params whether or not they were POSTed
    query.merge!({ :footnotes => f }) unless f.blank? 
    query.merge!({ :nikkud => n }) unless n.blank?
    query.merge!({ :status => s }) unless s.blank?
    # TODO: figure out how to include filter by path without making the query fugly
    if p.blank?
      @texts = HtmlFile.where(query).page(params[:page]).order('status ASC')
    else
      @texts = HtmlFile.where("path like ?", '%'+params[:path]+'%').page(params[:page]).order('status ASC')
    end  
    #@texts = HtmlFile.page(params[:page]).order('status ASC')
  end
  def parse
    @text = HtmlFile.find(params[:id])
    @text.parse
  end
  def unsplit
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path+'.markdown', 'r:UTF-8').read
    @markdown.gsub!('__SPLIT__','') # remove magic words
    @text.update_markdown(@markdown)
    redirect_to :action => :render_html, :id => params[:id]
  end
  def render_html
    @text = HtmlFile.find(params[:id])
    if params[:markdown].nil?
      @markdown = File.open(@text.path+'.markdown', 'r:UTF-8').read
    else
      @markdown = params[:markdown] # TODO: make secure
      @text.update_markdown(@markdown.gsub('__________','__SPLIT__') ) # TODO: add locking of some sort to avoid concurrent overwrites
    end
    @html = MultiMarkdown.new(@markdown.gsub('__SPLIT__','__________')).to_html.force_encoding('UTF-8') # TODO: figure out why to_html defaults to ASCII 8-bit
  end
  def chop3
    chopN(3)
    redirect_to :action => :render_html, :id => params[:id]
  end
  def chop2
    chopN(2)
    redirect_to :action => :render_html, :id => params[:id]
  end
  def chop1
    chopN(1)
    redirect_to :action => :render_html, :id => params[:id]
  end
  def publish
    @text = HtmlFile.find(params[:id])
    if @text.status == 'Parsed'
      @text.status = 'Published'
      markdown = File.open(@text.path+'.markdown', 'r:UTF-8').read
      title = HtmlFile.title_from_file(@text.path)
      @w = Work.new(:title => title)
      @e = Expression.new(:title => title, :language => "Hebrew")
      @w.expressions << @e
      @w.save!
      @m = Manifestation.new(:title => title, :responsibility_statement => HtmlFile.author_name_from_dir(@text.author_dir, {}), :medium => 'e-text', :publisher => AppConstants.our_publisher, :publication_date => Date.today, :markdown => markdown)
      @m.save!
      @e.manifestations << @m
      @e.save!
      @text.manifestations << @m
      @text.save!
    else
      flash[:error] = "Can't publish before parsing."
    end
  end

  protected
  def chopN(line_count)
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path+'.markdown', 'r:UTF-8').read
    lines = @markdown.split "\n"
    new_lines = []
    while line_count > 0
      line = lines.shift
      if line.match /\S/ and not line.match /#\s+\S+/ # ignore our own generated title / author line
        line_count -= 1 # skip one non-empty line and decrement
      else
        new_lines.push line # preserve whitespace lines
      end
      next
    end
    new_lines += lines # just append the remaining lines
    @markdown = new_lines.join "\n"
    File.open(@text.path+'.markdown', 'wb') {|f| f.write(@markdown) } # write back
  end
end
