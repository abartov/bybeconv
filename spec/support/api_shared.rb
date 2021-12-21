RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context 'API Spec Helpers', :shared_context => :metadata do
  def app
    Rails.application
  end
  let(:api_key) { create(:api_key) }
  let(:disabled_api_key) { create(:api_key, status: :disabled) }
  let(:json_response) { JSON.parse(response.body) }
  let(:error_message) { json_response['error'] }

  # Valid key value to be used in tests
  let(:key) { api_key.key }
end

RSpec.configure do |rspec|
  rspec.include_context "API Spec Helpers", :include_shared => true
end

