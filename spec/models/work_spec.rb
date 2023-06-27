require 'rails_helper'

describe Work do
  describe 'works_about' do
    let(:subject) { work.works_about.order(:id).to_a }
    let!(:work) { create(:work) }
    let!(:about_1)  {
      create(:work) do |w|
        create(:aboutness, work: w, aboutable: work)
      end
    }
    let!(:about_2)  {
      create(:work) do |w|
        create(:aboutness, work: w, aboutable: work)
      end
    }
    it { is_expected.to eq [about_1, about_2] }
  end
    
end