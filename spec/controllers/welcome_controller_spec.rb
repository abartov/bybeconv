require 'rails_helper'

describe WelcomeController do
  describe '#index' do

    before do
      # We need few persons with toc to fetch surprise author
      create_list(:manifestation, 5)
      Person.joins(:involvements).where(involved_authority: { role: :author}).each do |p|
        toc = create(:toc)
        p.toc = toc
        p.save!
      end
    end

    subject { get :index }

    it { is_expected.to be_successful }
  end
end

