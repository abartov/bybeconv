# frozen_string_literal: true

RSpec.shared_context 'when editor logged in' do |*bits|
  include_context 'when user logged in', *bits, editor: true
end
