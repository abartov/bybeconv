class ManifestationController < ApplicationController
  before_filter :require_editor, only: [:edit, :update]
  def read
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown.lines[1..-1].join("\n")).to_html.force_encoding('UTF-8')
    @tabclass = set_tab('works')
    @proof = Proof.new
  end
  def download
    @m = Manifestation.find(params[:id])
    case params[:format]
    when 'pdf'
    when 'doc'
    when 'txt'
      txt = html2txt(MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8'))
      begin
        temp_file = Tempfile.new('tmp_txt_'+@m.id.to_s,'tmp/')
        temp_file.puts(txt)
        temp_file.chmod(0644)
        send_file temp_file, type: 'text/plain', filename: @m.safe_filename+'.txt'
      ensure
        temp_file.close
      end
    when 'epub'
    when 'mobi'
    else
      flash[:error] = t(:unrecognized_format)
      redirect_back fallback_location: {action: read, id: @m.id}
    end
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
    p = params[:path]
    if p.blank?
      @manifestations = Manifestation.page(params[:page]).order('title ASC')
    else
      @manifestations = Manifestation.where('path like ?', '%' + p + '%').page(params[:page]).order('title ASC')
    end
  end

  def show
    @m = Manifestation.find(params[:id])
    @e = @m.expressions[0] # TODO: generalize?
    @w = @e.works[0] # TODO: generalize!

  end

  def render_html
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8')
  end

  def edit
  end

end
