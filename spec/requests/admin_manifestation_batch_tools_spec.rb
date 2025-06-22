require 'rails_helper'

describe 'Admin Manifestation Batch Tools', type: :request do
  let(:admin) { User.create!(email: 'admin@example.com', password: 'password', admin: true) }
  let!(:manifestations) do
    [
      Manifestation.create!(title: 'Test 1', author_string: 'Author 1', status: :published),
      Manifestation.create!(title: 'Test 2', author_string: 'Author 2', status: :published)
    ]
  end

  before do
    sign_in admin
  end

  it 'renders the batch tool page for admins' do
    get manifestation_batch_tools_admin_index_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Manifestation Batch Tools')
  end

  it 'lists manifestations by whitespace-delimited IDs' do
    get manifestation_batch_tools_admin_index_path(ids: manifestations.map(&:id).join(' '))
    expect(response.body).to include('Test 1')
    expect(response.body).to include('Test 2')
  end

  it 'deletes a manifestation' do
    expect {
      delete destroy_manifestation_admin_index_path(id: manifestations.first.id)
    }.to change { Manifestation.count }.by(-1)
  end

  it 'unpublishes a manifestation' do
    post unpublish_manifestation_admin_index_path(id: manifestations.last.id)
    expect(manifestations.last.reload.status).to eq('unpublished')
  end

  it 'denies access to non-admins' do
    sign_out admin
    user = User.create!(email: 'user@example.com', password: 'password', admin: false)
    sign_in user
    get manifestation_batch_tools_admin_index_path
    expect(response).to have_http_status(:redirect)
  end
end
