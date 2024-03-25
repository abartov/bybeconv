require 'rails_helper'

RSpec.describe InvolvedAuthority, type: :model do
  describe 'validations' do
    it 'validates presence of all fields' do
      ia = InvolvedAuthority.new
      expect(ia).to_not be_valid
      ia.authority = create(:person)
      expect(ia).to_not be_valid
      ia.item = create(:work)
      expect(ia).to_not be_valid
      ia.role = InvolvedAuthority.roles.keys.sample
      expect(ia).to be_valid
    end
  end
end
