require 'rails_helper'

describe WelcomeController do
  describe '#index' do
    subject { get :index }

    before do
      create_list(:manifestation, 5)
    end

    it { is_expected.to be_successful }

    context 'when featured author present' do
      before do
        create_list(:featured_author, 3)
      end

      it { is_expected.to be_successful }
    end
  end

  describe '#featured_author_popup' do
    subject { get :featured_author_popup, params: { id: featured_author.id } }

    context 'when featured author is male' do
      let(:featured_author) do
        create(:featured_author, person: create(:person, gender: :male))
      end

      it { is_expected.to be_successful }
    end

    context 'when featured author is female' do
      let(:featured_author) do
        create(:featured_author, person: create(:person, gender: :female))
      end

      it { is_expected.to be_successful }
    end
  end

  describe '#contact' do
    subject { get :contact }

    it { is_expected.to be_successful }
  end

  describe '#submit_contact' do
    let(:email) { 'john.doe@test.com' }
    let(:ziburit) { 'ביאליק' }
    let(:errors) { assigns(:errors) }

    let(:params) do
      {
        name: 'John Doe',
        phone: '123456789',
        email: email,
        topic: 'other',
        body: 'Topic',
        rtopic: 'other',
        ziburit: ziburit
      }
    end

    subject(:request) { post :submit_contact, params: params, format: :js }

    before do
      allow(Notifications).to receive(:contact_form_submitted).and_call_original
      request
    end

    context 'when everything is OK' do
      it { is_expected.to be_successful }
      it { expect(errors).to be_empty }
      it { expect(Notifications).to have_received(:contact_form_submitted).once }
    end

    context 'when email is missing' do
      let(:email) { ' ' }

      it { is_expected.to be_successful }
      it { expect(errors).to eq([I18n.t('welcome.submit_contact.email_missing')]) }
      it { expect(Notifications).not_to have_received(:contact_form_submitted) }
    end

    context 'when control question failed' do
      let(:ziburit) { 'WRONG' }

      it { is_expected.to be_successful }
      it { expect(errors).to eq([I18n.t('welcome.submit_contact.ziburit_failed')]) }
      it { expect(Notifications).not_to have_received(:contact_form_submitted) }
    end
  end
end
