require 'rails_helper'

describe ManifestationController do
  before(:all) do
    clean_tables
    Chewy.strategy(:atomic) do
      create_list(:manifestation, 10)
    end
  end

  describe 'Browse' do
    subject { get :browse, params: { sort_by: "#{sort_by}_#{sort_dir}" } }

    # Simply ensure all sort combinations works
    %w(alphabetical pupularity creation_date publication_date upload_date).each do | sort_by |
      %w(asc desc).each do |dir|
        context "when #{dir} sorting by #{sort_by} is requested" do
          let(:sort_by) { sort_by }
          let(:sort_dir) { dir }
          it { is_expected.to be_successful }
        end
      end
    end
  end
end