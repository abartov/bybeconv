# frozen_string_literal: true

require 'rails_helper'

describe CorporateBodiesController do
  let(:user) { create(:user, editor: true, admin: true) }

  before do
    create(:list_item, item: user, listkey: :edit_people)
    session[:user_id] = user.id
  end

  describe '#index' do
    let!(:bodies) { create_list(:corporate_body, 5) }
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe '#show' do
    let!(:corporate_body) { create(:corporate_body) }
    subject { get :show, params: { id: corporate_body.id } }
    it { is_expected.to be_successful }
  end

  describe '#new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe '#create' do
    let(:params) do
      {
        corporate_body: {
          status: status,
          name: 'Name',
          wikipedia_url: 'https://1.com'
        }
      }
    end

    subject(:call) { post :create, params: params }

    context 'when validation succeed' do
      let(:status) { 'awaiting_first' }

      it 'creates new record' do
        expect { call }.to change { CorporateBody.count }.by(1)
        record = CorporateBody.order(id: :desc).first
        expect(call).to redirect_to record
        expect(flash.notice).to eq I18n.t('corporate_bodies.create.success')
        expect(record).to have_attributes(params[:corporate_body])
      end
    end

    context 'when some validation fails' do
      let(:status) { nil }

      it 'does not creates record and re-renders form' do
        expect { call }.not_to(change { CorporateBody.count })
        expect(call).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#edit' do
    let!(:corporate_body) { create(:corporate_body) }

    subject { get :edit, params: { id: corporate_body.id } }

    it { is_expected.to be_successful }
  end

  describe '#update' do
    let!(:corporate_body) { create(:corporate_body) }

    let(:params) do
      {
        corporate_body: {
          status: status,
          name: 'New Name',
          wikipedia_url: 'https://new.com'
        },
        id: corporate_body.id
      }
    end

    subject(:call) { patch :update, params: params }

    context 'when validation passed' do
      let(:status) { 'published' }

      it 'updates record' do
        expect(call).to redirect_to corporate_body

        corporate_body.reload
        expect(corporate_body).to have_attributes(params[:corporate_body])
        expect(flash.notice).to eq I18n.t('corporate_bodies.update.success')
      end
    end

    context 'when some validation fails' do
      let(:status) { nil }

      it 're-renders edit form' do
        expect(call).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#destroy' do
    let!(:corporate_body) { create(:corporate_body) }

    subject(:call) { delete :destroy, params: { id: corporate_body.id } }

    it 'destroys record' do
      expect { call }.to change { CorporateBody.count }.by(-1)
      expect(:call).to redirect_to corporate_bodies_path
      expect(flash.notice).to eq I18n.t('corporate_bodies.destroy.success')
    end
  end
end
