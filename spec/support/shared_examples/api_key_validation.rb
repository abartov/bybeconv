RSpec.shared_examples 'Unauthorized API call' do
  it 'fails with unauthorized status' do
    expect(call).to eq 401
    expect(error_message).to eq 'key not found or disabled'
  end
end

RSpec.shared_examples 'API Key Check' do
  context 'when key is empty' do
    let(:key) { nil }
    include_context 'Unauthorized API call'
  end

  context 'when key is disabled' do
    let(:key) { disabled_api_key.key }
    include_context 'Unauthorized API call'
  end

  context 'when key is wrong' do
    let(:key) { 'WRONG KEY' }
    include_context 'Unauthorized API call'
  end
end
