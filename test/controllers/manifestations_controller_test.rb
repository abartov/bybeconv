require 'test_helper'

class ManifestationControllerTest < ActionController::TestCase
  def setup
    Chewy.massacre
    Chewy.strategy(:atomic) do
      create_list(:manifestation, 50)
    end
  end

  test 'browse with different sortings works' do
    # Simply ensure all sort combinations works
    %w(alphabetical pupularity creation_date publication_date upload_date).each do | sort_by |
      %w(asc desc).each do |dir|
        get :browse, params: { sort_by: "#{sort_by}_#{dir}" }
        assert_response :success
      end
    end
  end
end