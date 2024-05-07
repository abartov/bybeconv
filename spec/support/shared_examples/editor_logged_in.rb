# frozen_string_literal: true

RSpec.shared_context 'when editor logged in' do
  let(:editor) { create(:user, editor: true) }

  before do
    session[:user_id] = editor.id
  end
end
