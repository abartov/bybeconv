# frozen_string_literal: true

require 'rails_helper'

describe IngestibleTextsController do
  include_context 'when editor logged in', :edit_catalog

  let!(:ingestible) { create(:ingestible, :with_buffers) }

  describe '#edit' do
    subject(:call) { get :edit, params: { ingestible_id: ingestible.id, id: 2 }, format: :js, xhr: true }

    it 'completes successfully' do
      expect(call).to have_http_status(:success)
    end

    context 'when text has footnotes' do
      let!(:text_with_footnotes) do
        IngestibleText.new({ 'title' => 'Test Title', 'content' => "Text with footnote[^1].\n\n[^1]: Footnote text" })
      end

      before do
        ingestible.texts[2] = text_with_footnotes
        ingestible.save!
        call
      end

      it 'generates HTML with unique footnote anchors for this text' do
        text_html = controller.instance_variable_get(:@text_html)
        expect(text_html).to be_present
        # Check that footnote anchors have the text-specific nonce
        expect(text_html).to include('fn:txt_2_1')
        expect(text_html).to include('fnref:txt_2_1')
        # Ensure the anchors are not left with generic IDs
        expect(text_html.scan('id="fn:1"').count).to eq(0)
      end
    end
  end

  describe '#update' do
    subject(:call) do
      patch :update, params: { ingestible_id: ingestible.id, id: 2, ingestible_text: text_params, format: :js }
    end

    let(:text_params) do
      {
        title: 'new_title',
        content: 'new_content'
      }
    end

    it 'updates ingestible and redirects to ingestible edit page' do
      expect(call).to redirect_to edit_ingestible_path(ingestible, text_index: 2)
      ingestible.reload
      expect(flash.notice).to eq I18n.t(:updated_successfully)
      expect(ingestible.texts[2]).to have_attributes(text_params)
    end
  end
end
