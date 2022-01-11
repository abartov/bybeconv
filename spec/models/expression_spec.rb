require 'rails_helper'

describe Expression do
  describe '.cached_work_counts_by_periods' do
    let(:subject) { Expression.cached_work_count_by_periods }

    before do
      create(:manifestation, status: :unpublished, expressions: [ create(:expression, period: :ancient) ])
      create(:manifestation, expressions: [ create(:expression, period: :ancient) ])
      create(:manifestation, expressions: [ create(:expression, period: :medieval) ])
      create(:manifestation, expressions: [ create(:expression, period: :medieval) ])
    end

    it 'does not counts unpublished works' do
      expect(subject.size).to eq 2
      expect(subject['ancient']).to eq 1
      expect(subject['medieval']).to eq 2
    end
  end
end