require 'rails_helper'

describe 'shared/_anth_panel.html.haml' do
  subject(:render_partial) { render partial: 'shared/anth_panel.html.haml' }

  let(:user) { create(:user) }
  let(:manifestation) { create(:manifestation) }
  let(:anthology) { create(:anthology, user: user, manifestations: [manifestation])}

  before do
    assign(:anthology, anthology)
    assign(:cur_anth_id, anthology.id)

    # this is a work-around to make current_user helper method available in partial
    assign(:user, user)
    view.class_eval do
      def current_user
        @user
      end
    end
  end

  it 'renders' do
    render partial: 'shared/anth_panel.html.haml'
  end
end