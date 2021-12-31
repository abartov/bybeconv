require 'rails_helper'

describe Manifestation do
  describe '.safe_filename' do
    let(:manifestation) { create(:manifestation) }
    let(:subject) { manifestation.safe_filename }

    it { is_expected.to eq manifestation.id.to_s }
  end
end