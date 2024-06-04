# frozen_string_literal: true

RSpec.shared_context 'when editor logged in' do |*bits|
  let(:current_user) { create(:user, editor: true) }

  before do
    bits.to_a.each do |bit|
      ListItem.create!(listkey: bit, item: current_user)
    end

    session[:user_id] = current_user.id
  end
end
