# frozen_string_literal: true

require 'rails_helper'

describe CleanUpBaseUsers do
  self.use_transactional_tests = false

  subject(:call) { described_class.call }

  let!(:registered_user) { create(:base_user, :registered, :with_bookmarks, :with_preferences, bookmarks_count: 3) }
  let!(:stale_users) { create_list(:base_user, 5, :with_bookmarks, :with_preferences, bookmarks_count: 5) }

  let(:new_unregistered_user) do
    create(:base_user, :unregistered, :with_bookmarks, :with_preferences, bookmarks_count: 3)
  end

  after(:all) do
    clean_tables
  end

  it 'cleans up unregistered users not having record in sessions table and their bookmarks' do
    expect { call }.to change(BaseUser, :count).by(-5).and change(Bookmark, :count).by(-25)
    expect { new_unregistered_user.reload }.not_to raise_error
    expect { registered_user.reload }.not_to raise_error
  end
end
