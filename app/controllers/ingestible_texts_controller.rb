# frozen_string_literal: true

# Controller to work with individual texts within an Ingestible object
class IngestibleTextsController < ApplicationController
  include LockIngestibleConcern
  include BybeUtils

  before_action { |c| c.require_editor('edit_catalog') }
  before_action :set_ingestible
  before_action :try_to_lock_ingestible

  def edit
    @text = @ingestible.texts[@text_index]
    # Generate HTML with unique footnote anchors for this specific text
    texthtml = highlight_suspicious_markdown(MarkdownToHtml.call(@text.content))
    @text_html = footnotes_noncer(texthtml, "txt_#{@text_index}")
  end

  def update
    @ingestible.texts[@text_index] = IngestibleText.new(params.require(:ingestible_text).permit(:content, :title))
    @ingestible.save!
    redirect_to edit_ingestible_path(@ingestible, text_index: @text_index), notice: t(:updated_successfully)
  end

  private

  def set_ingestible
    @ingestible = Ingestible.find(params[:ingestible_id])
    # Id is a zero-based index of text inside of ingestible texts collection
    @text_index = params[:id].to_i
  end
end
