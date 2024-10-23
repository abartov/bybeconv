# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsMigrationController do
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #person' do
    it 'returns http success' do
      get :person
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #migrate' do
    it 'returns http success' do
      get :migrate
      expect(response).to have_http_status(:success)
    end
  end
end
