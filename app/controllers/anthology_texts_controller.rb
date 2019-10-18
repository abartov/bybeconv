class AnthologyTextsController < ApplicationController
  before_action :set_anthology_text, only: [:show, :edit, :update, :destroy]

  # POST /anthology_texts
  def create
    @anthology_text = AnthologyText.new(anthology_text_params)
    @anthology_text.title = @anthology_text.manifestation.title_and_authors unless @anthology_text.manifestation_id.nil?
    @anthology = @anthology_text.anthology
    @cur_anth_id = @anthology.nil? ? 0 : @anthology.id
    respond_to do |format|
      if @anthology_text.save
        @anthology.append_to_sequence(@anthology_text.id)
        format.js
        format.html {redirect_to @anthology_text, notice: 'Anthology text was successfully created.'}
      else
        render :new
      end
    end
  end

  def edit
    @curated = @anthology_text
  end

  def update
    if @anthology_text.update(anthology_text_params)
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    unless @anthology_text.nil?
      @anthology.remove_from_sequence(@anthology_text.id)
      @deleted_id = @anthology_text.id.to_s
      @anthology_text.destroy!
      respond_to do |format|
        format.js # destroy.js.erb
      end
    end
  end

  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_anthology_text
    @anthology_text = AnthologyText.find(params[:id])
    unless @anthology_text.nil?
      @anthology = @anthology_text.anthology
      @cur_anth_id = @anthology.nil? ? 0 : @anthology.id
    end
  end

  def anthology_text_params
    params.require(:anthology_text).permit(:title, :body, :manifestation_id, :anthology_id)
  end
end
