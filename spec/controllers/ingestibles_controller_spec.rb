# frozen_string_literal: true

require 'rails_helper'

describe IngestiblesController do
  include_context 'when editor logged in', :edit_catalog

  describe '#index' do
    subject { get :index }

    before do
      create_list(:ingestible, 5)
    end

    it { is_expected.to be_successful }
  end

  describe '#new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe '#create' do
    subject(:call) { post :create, params: { ingestible: ingestible_params } }

    context 'with valid params' do
      let(:ingestible_params) do
        attributes_for(:ingestible)
      end

      it 'creates new record and redirects to edit page' do
        expect { call }.to change(Ingestible, :count).by(1)
        ingestible = Ingestible.order(id: :desc).first
        expect(call).to redirect_to edit_ingestible_path(ingestible)
        expect(flash.notice).to eq I18n.t('ingestibles.create.success')
      end
    end

    context 'with invalid params' do
      let(:ingestible_params) do
        attributes_for(:ingestible, title: nil)
      end

      it 're-renders new page' do
        expect { call }.to not_change(Ingestible, :count)
        expect(call).to render_template(:new)
      end
    end
  end

  describe 'Member Actions' do
    let!(:ingestible) { create(:ingestible, locked_by_user: locked_by_user, locked_at: locked_at) }
    let(:locked_by_user) { nil }
    let(:locked_at) { nil }

    shared_examples 'redirects to show page if record cannot be locked' do
      context 'when record is locked by other user' do
        let(:locked_by_user) { create(:user) }
        let(:locked_at) { 5.minutes.ago }

        it 'redirects to show page and shows alert' do
          expect(call).to redirect_to ingestibles_path
          expect(flash.alert).to eq I18n.t('ingestibles.ingestible_locked', user: locked_by_user.name)
        end
      end
    end

    describe '#show' do
      subject { get :show, params: { id: ingestible.id } }

      it { is_expected.to be_successful }
    end

    describe '#edit' do
      subject(:call) { get :edit, params: { id: ingestible.id } }

      it_behaves_like 'redirects to show page if record cannot be locked'

      it { is_expected.to be_successful }

      context 'when ingestible has works with footnotes' do
        let(:ingestible) { create(:ingestible, :with_footnotes) }

        before do
          ingestible.update_parsing
          call
        end

        it 'generates HTML with unique footnote anchors for each section' do
          html = controller.instance_variable_get(:@html)
          expect(html).to be_present
          # Check that footnote anchors from different sections have different nonces
          expect(html).to include('fn:md_0_1') # First section's footnote
          expect(html).to include('fn:md_1_1') # Second section's footnote
          # Ensure the anchors are not duplicated without nonces
          expect(html.scan('id="fn:1"').count).to eq(0)
        end
      end
    end

    describe '#update' do
      subject(:call) { patch :update, params: { id: ingestible.id, ingestible: ingestible_params } }

      let(:ingestible_params) { attributes_for(:ingestible).except(:markdown, :toc_buffer) }

      it_behaves_like 'redirects to show page if record cannot be locked'

      context 'when valid params' do
        it 'updates record and re-renders edit page' do
          expect(call).to redirect_to edit_ingestible_path(ingestible)
          ingestible.reload
          expect(ingestible).to have_attributes(ingestible_params)
          expect(flash.notice).to eq I18n.t('ingestibles.update.success')
        end
      end

      context 'when invalid params' do
        let(:ingestible_params) { attributes_for(:ingestible, title: nil) }

        it 're-renders edit form' do
          expect(call).to have_http_status(:unprocessable_content)
          expect(call).to render_template(:edit)
        end
      end
    end

    describe '#update_markdown' do
      subject(:call) { patch :update_markdown, params: { id: ingestible.id, ingestible: { markdown: new_markdown } } }

      let(:new_markdown) { Faker::Lorem.paragraph }

      it_behaves_like 'redirects to show page if record cannot be locked'

      it 'updates record and re-renders edit page' do
        expect(call).to redirect_to "#{edit_ingestible_path(ingestible)}?tab=full_markdown"
        ingestible.reload
        expect(ingestible.markdown).to eq new_markdown
        expect(flash.notice).to eq I18n.t(:updated_successfully)
      end
    end

    describe '#destroy' do
      subject(:call) { delete :destroy, params: { id: ingestible.id } }

      it_behaves_like 'redirects to show page if record cannot be locked'

      it 'removes record and redirects to index page' do
        expect { call }.to change(Ingestible, :count).by(-1)
        expect(call).to redirect_to ingestibles_path
        expect(flash.notice).to eq I18n.t('ingestibles.destroy.success')
      end
    end
  end
end
