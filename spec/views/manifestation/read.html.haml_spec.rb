require 'rails_helper'

describe 'manifestation/read.html.haml' do
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
    assign(:author, manifestation.authors.first)
    assign(:translators, manifestation.translators)
    assign(:illustrators, work.illustrators)
    assign(:editors, expression.editors)
    assign(:taggings, manifestation.taggings)
    assign(:recommendations, manifestation.recommendations)
    assign(:works_about, work.works_about)
    assign(:pagetype, :manifestation)
    assign(:header_partial, 'manifestation/work_top')

    view.class_eval do
      def current_user
        nil
      end
    end
  end

  it 'renders' do
    render template: 'manifestation/read.html.haml', layout: 'layouts/application'
  end
end