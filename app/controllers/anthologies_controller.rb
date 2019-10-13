class AnthologiesController < ApplicationController
  before_action :set_anthology, only: [:show, :print, :seq, :download, :edit, :update, :destroy]

  # GET /anthologies
  def index
    @anthologies = Anthology.all
  end

  # GET /anthologies/1
  def show
    if @anthology.accessible?
      prep_for_show
    else
      redirect_to '/', error: t(:no_permission)
    end
  end

  def download
    if @anthology.accessible?
      prep_for_show
      # impressionist(@m) unless is_spider? # TODO: enable impressionist for anthologies
      filename = "#{@anthology.title.gsub(/[^0-9א-תA-Za-z.\-]/, '_')}.#{params[:format]}"
      html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"he\" lang=\"he\" dir=\"rtl\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head><body dir='rtl' align='right'><div dir=\"rtl\" align=\"right\">#{@anthology.title}"+@htmls.map{|h| "<h1>#{h[0]}</h1>\n#{h[1]}"}.join("\n").force_encoding('UTF-8')+"\n\n<hr />"+I18n.t(:download_footer_html, url: url_for(action: :show, id: @anthology.id))+"</div></body></html>"
      do_download(params[:format], filename, html, @anthology)
    else
      redirect_to '/', error: t(:no_permission)
    end
  end

  def print
    if @anthology.accessible?
      prep_for_show
    else
      redirect_to '/', error: t(:no_permission)
    end
  end

  def seq
    p = params.permit(:id,:old_pos, :new_pos, :anth_text_id)
    @anthology.update_sequence(p[:anth_text_id].to_i, p[:old_pos].to_i, p[:new_pos].to_i)
  end

  # GET /anthologies/new
  def new
    @anthology = Anthology.new
  end

  # GET /anthologies/1/edit
  def edit
  end

  # POST /anthologies
  def create
    @anthology = Anthology.new(anthology_params)

    if @anthology.save
      redirect_to @anthology, notice: 'Anthology was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /anthologies/1
  def update
    if @anthology.update(anthology_params)
      redirect_to @anthology, notice: 'Anthology was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /anthologies/1
  def destroy
    @anthology.destroy
    redirect_to anthologies_url, notice: 'Anthology was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_anthology
      @anthology = Anthology.find(params[:id])
    end

    def anthology_params
      params.require(:anthology).permit(:title, :access, :sequence)
    end

    def prep_for_show
      @htmls = []
      @anthology.ordered_texts.each {|text|
        @htmls << [text.title, text.render_html]
      }
    end
end
