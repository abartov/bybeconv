require 'rails_helper'

describe WelcomeController do
  describe '#index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end
end

