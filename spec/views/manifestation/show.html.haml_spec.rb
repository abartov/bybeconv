require 'rails_helper'

describe 'manifestation/show.html.haml' do
  let(:illustrator) { create(:person) }
  let(:editor) { create(:person) }
  let(:manifestation) { create(:manifestation, orig_lang: 'ru', illustrator: illustrator, editor: editor) }
  let(:expression) { manifestation.expressions[0] }
  let(:work) { expression.works[0] }

  before do
    assign(:m, manifestation)
    assign(:entity, manifestation)
    assign(:e, expression)
    assign(:w, work)
    assign(:pagetitle, 'page title')

    view.class_eval do
      def current_user
        nil
      end
    end
  end

  it 'renders' do
    render
  end
end