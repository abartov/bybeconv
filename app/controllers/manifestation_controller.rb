require 'pandoc-ruby'

class ManifestationController < ApplicationController
  before_filter :require_editor, only: [:list, :show, :edit, :update, :remove_link, :edit_metadata]

  impressionist # log actions for pageview stats

  #layout false, only: [:print]

  #############################################
  # public actions
  def works # /works dashboard
    @tabclass = set_tab('works')
    # TODO
  end

  def whatsnew
    @tabclass = set_tab('works')
    # TODO
  end

  def read
    prep_for_read
    @proof = Proof.new
    @print_url = url_for(action: :print, id: @m.id)
    @links = @m.external_links.group_by {|l| l.linktype}
  end

  def readmode
    @readmode = true
    prep_for_read
  end

  def print
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown.lines[1..-1].join("\n")).to_html.force_encoding('UTF-8')
    @print = true
  end

  def download
    @m = Manifestation.find(params[:id])
    filename = @m.safe_filename+'.'+params[:format]
    html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"he\" lang=\"he\" dir=\"rtl\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head><body dir='rtl' align='right'><div dir=\"rtl\" align=\"right\">"+MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8')+"\n\n<hr />"+I18n.t(:download_footer_html, url: url_for(action: :read, id: @m.id))+"</div></body></html>"
    case params[:format]
    when 'pdf'
      pdfname = HtmlFile.pdf_from_any_html(html)
      pdf = File.read(pdfname)
      send_data pdf, type: 'application/pdf', filename: filename
      File.delete(pdfname) # delete temporary generated PDF
    when 'doc'
      begin
        temp_file = Tempfile.new('tmp_doc_'+@m.id.to_s, 'tmp/')
        temp_file.puts(PandocRuby.convert(html, M: 'dir=rtl', from: :html, to: :docx).force_encoding('UTF-8')) # requires pandoc 1.17.3 or higher, for correct directionality
        temp_file.chmod(0644)
        send_file temp_file, type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', filename: filename
      ensure
        temp_file.close
      end
    when 'html'
      begin
        temp_file = Tempfile.new('tmp_html_'+@m.id.to_s, 'tmp/')
        temp_file.puts(html)
        temp_file.chmod(0644)
        send_file temp_file, type: 'text/html', filename: filename
      ensure
        temp_file.close
      end
    when 'txt'
      txt = html2txt(html)
      txt.gsub!("\n","\r\n") if params[:os] == 'Windows' # windows linebreaks
      begin
        temp_file = Tempfile.new('tmp_txt_'+@m.id.to_s,'tmp/')
        temp_file.puts(txt)
        temp_file.chmod(0644)
        send_file temp_file, type: 'text/plain', filename: filename
      ensure
        temp_file.close
      end
    when 'epub'
      begin
        epubname = make_epub_from_single_html(html, @m)
        epub_data = File.read(epubname)
        send_data epub_data, type: 'application/epub+zip', filename: filename
        File.delete(epubname) # delete temporary generated EPUB
      end
    when 'mobi'
      begin
        # TODO: figure out how not to go through epub
        epubname = make_epub_from_single_html(html, @m)
        mobiname = epubname[epubname.rindex('/')+1..-6]+'.mobi'
        out = `kindlegen #{epubname} -c1 -o #{mobiname}`
        mobiname = epubname[0..-6]+'.mobi'
        mobi_data = File.read(mobiname)
        send_data mobi_data, type: 'application/x-mobipocket-ebook', filename: filename
        File.delete(epubname) # delete temporary generated EPUB
        File.delete(mobiname) # delete temporary generated MOBI
      end
    else
      flash[:error] = t(:unrecognized_format)
      redirect_back fallback_location: {action: read, id: @m.id}
    end
  end

  def render_html
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8')
  end

  def genre
    @tabclass = set_tab('works')
    @manifestations = Manifestation.joins(:expressions).where(expressions: {genre: params[:genre]}).page(params[:page]).order('title ASC')
  end

  def get_random
    work = Manifestation.order('RAND()').limit(1)[0]
    render partial: 'shared/surprise_work', locals: {manifestation: work}
  end
  #############################################
  # editor actions

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
    @total = Manifestation.count
    # form input
    unless params[:commit].blank?
      session[:mft_q_params] = params # make prev. params accessible to view
    else
      session[:mft_q_params] = { title: '', author: '' }
    end

    # DB
    if params[:title].blank? && params[:author].blank?
      @manifestations = Manifestation.page(params[:page]).order('title ASC')
    else
      if params[:author].blank?
        @manifestations = Manifestation.where('title like ?', '%' + params[:title] + '%').page(params[:page]).order('title ASC')
      elsif params[:title].blank?
        @manifestations = Manifestation.where('cached_people like ?', "%#{params[:author]}%").page(params[:page]).order('title asc')
      else # both author and title
        @manifestations = Manifestation.where('manifestations.title like ? and manifestations.cached_people like ?', '%' + params[:title] + '%', '%'+params[:author]+'%').page(params[:page]).order('title asc')
      end
    end
  end

  def show
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8')
  end

  def edit
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8')
  end

  def edit_metadata
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
  end

  def update
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!
    # update attributes
    if params[:markdown].nil? # metadata edit
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
      unless params[:add_url].blank?
        l = ExternalLink.new(url: params[:add_url], linktype: params[:link_type], description: params[:link_description], status: Manifestation.statuses[:approved])
        l.manifestation = @m
        l.save!
      end
      @w.save!
      @e.save!
    else # markdown edit
      @m.markdown = params[:markdown]
    end
    @m.save!
    @m.recalc_cached_people!
    flash[:notice] = I18n.t(:updated_successfully)
    redirect_to action: :show, id: @m.id
  end

  protected

  def prep_for_read
    @m = Manifestation.find(params[:id])
    lines = @m.markdown.lines
    tmphash = {}
    @chapters = {}
    @m.heading_lines.reverse.each{ |linenum|
      lines.insert(linenum, "<a name=\"ch#{linenum}\"></a>")
      tmphash[sanitize_heading(lines[linenum+1][2..-1].strip)] = linenum.to_s
    } # annotate headings in reverse order, to avoid offsetting the next heading
    tmphash.keys.reverse.map{|k| @chapters[k] = tmphash[k]}
    @selected_chapter = tmphash.keys.last
    @html = MultiMarkdown.new(lines[1..-1].join("\n")).to_html.force_encoding('UTF-8')
    @tabclass = set_tab('works')
    @entity = @m
    @pagetype = :manifestation
    @page_title = "#{@m.title} - #{t(:default_page_title)}"
    @author = @m.expressions[0].works[0].persons[0] # TODO: handle multiple authors
    @translator = @m.expressions[0].persons[0] # TODO: handle multiple translators
    impressionist(@author) # increment the author's popularity counter
  end
end
