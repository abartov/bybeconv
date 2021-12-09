RSpec.shared_context 'Admin user logged in' do
  let(:admin) { create(:user, editor: true, admin: true) }
  before do
    session[:user_id] = admin.id
  end
end

RSpec.shared_examples 'Failed to access admin page' do
  it 'redirects to root page' do
    expect(subject).to redirect_to '/'
  end
end

RSpec.shared_examples 'Unauthorized access to admin page' do
  context 'when user doesn\'t have admin rights' do
    context 'when user is not authorized' do
      before do
        session[:user_id] = nil
      end
      include_context 'Failed to access admin page'
    end

    context 'when regular user is authorized' do
      let!(:user) { create(:user) }
      before do
        session[:user_id] = user.id
      end
      include_context 'Failed to access admin page'
    end

    context 'when editor is authorized' do
      let!(:user) { create(:user, admin: false, editor: true) }
      before do
        session[:user_id] = user.id
      end
      include_context 'Failed to access admin page'
    end
  end
end
