class AnthologyTextsController < ApplicationController
  before_action :set_anthology_text, only: [:show, :edit, :update, :destroy]

  # POST /anthology_texts
  def create
    @anthology_text = AnthologyText.new(anthology_text_params)
    @anthology_text.title = @anthology_text.manifestation.title_and_authors unless @anthology_text.manifestation_id.nil?
    @anthology = @anthology_text.anthology
    @cur_anth_id = @anthology.nil? ? 0 : @anthology.id
    begin
      if @anthology_text.save
        respond_to do |format|
          @anthology.append_to_sequence(@anthology_text.id)
          format.js
          format.html {redirect_to @anthology_text, notice: 'Anthology text was successfully created.'}
        end
      else
        respond_with_error
      end
    rescue ActiveRecord::RecordInvalid
      respond_with_error
    end
  end

  def respond_with_error
    # show anthErrorDlg if necessary
    @cur_anth_id = (@anthology.nil? || @anthology.id.nil?) ? 0 : @anthology.id
    @error = true
    response.status = 200
    respond_to do |format|
      format.js
      format.html {redirect_to @anthology_text, notice: @anthology_text.errors[:base][0]}
    end
  end

  def confirm_destroy
    @at = AnthologyText.find(params[:anthology_text_id])
    render partial: 'confirm_destroy'
  end
  def mass_create
    @anthology = nil
    @skipped_records = 0
    @added_records = 0
    if params[:anthology_texts]
      params[:anthology_texts].each do |atext|
        at = AnthologyText.new(select_permitted(atext[1]))
        unless at.anthology.nil?
          @anthology = at.anthology
          at.title = at.manifestation.title_and_authors unless at.manifestation_id.nil?
          begin
            at.save!
            at.anthology.append_to_sequence(at.id)
            @added_records += 1
          rescue ActiveRecord::RecordInvalid
            @skipped_records += 1
          end
        end
      end
    end
    @cur_anth_id = @anthology.nil? ? 0 : @anthology.id
  end

  def select_permitted(atext)
    atext.permit(:manifestation_id, :anthology_id)
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
