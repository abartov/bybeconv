class AnthologyTextsController < ApplicationController
  before_action :set_anthology_text, only: [:show, :update, :destroy]

  # POST /anthology_texts
  def create
    @anthology_text = AnthologyText.new(anthology_text_params)
    @anthology = @anthology_text.anthology
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

  def update
  end

  def destroy
  end

  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_anthology_text
    @anthology_text = AnthologyText.find(params[:id])
  end

  def anthology_text_params
    params.require(:anthology_text).permit(:title, :body, :manifestation_id, :anthology_id)
  end
end
