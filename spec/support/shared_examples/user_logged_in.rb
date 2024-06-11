# frozen_string_literal: true

RSpec.shared_context 'when user logged in' do |*bits, admin: false, editor: false|
  let(:current_user) { create(:user, admin: admin, editor: editor) }

  before do
    bits.each do |bit|
      ListItem.create!(listkey: bit, item: current_user)
    end

    session[:user_id] = current_user.id
  end
end
