require 'rails_helper'

describe 'manifestation/edit_metadata.html.haml' do
  let(:manifestation) { create(:manifestation) }
  let(:expression) { manifestation.expressions[0] }
  let(:work) { expression.works[0] }
  let(:user) { create(:user, :edit_catalog) }

  before do
    assign(:user, user)
    assign(:m, manifestation)
    assign(:e, expression)
    assign(:w, work)
    view.class_eval do
      def current_user
        @user
      end
    end
  end

  it 'renders' do
    render
  end
end