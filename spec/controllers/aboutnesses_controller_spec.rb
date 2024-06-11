require 'rails_helper'

describe AboutnessesController do
  let(:manifestation) { create(:manifestation) }
  let(:work) { manifestation.expression.work }
  let(:editor) { create(:user, editor: true) }

  before do
    session[:user_id] = editor.id
  end

  describe '#create' do
    let(:suggested_by_user) { create(:user) }
    subject(:request) { post :create, params: { work_id: work.id, suggested_by: suggested_by_user.id, aboutness_type: aboutness_type }.merge(additional_params), format: :js }

    let(:aboutness) { Aboutness.order(id: :desc).first }

    context 'when aboutness is a Work' do
      let(:aboutness_type) { 'Work' }
      let(:work_about) { create(:manifestation) }
      let(:additional_params) { { add_work_topic: work_about.id } }

      it 'creates record' do
        expect { expect(request).to be_successful }.to change { Aboutness.where(work: work).count }.by(1)
        expect(aboutness).to have_attributes(work: work, aboutable: work_about.expression.work, user: suggested_by_user)
      end
    end

    context 'when aboutness is an Authority' do
      let(:aboutness_type) { 'Authority' }
      let(:authority_about) { create(:authority) }
      let(:additional_params) { { add_authority_topic: authority_about.id } }

      it 'creates record' do
        expect { expect(request).to be_successful }.to change { Aboutness.where(work: work).count }.by(1)
        expect(aboutness).to have_attributes(work: work, aboutable: authority_about, user: suggested_by_user)
      end
    end

    context 'when aboutness is a Wikidata' do
      let(:aboutness_type) { 'Wikidata' }
      let(:add_external_topic) { 'q12345' }
      let(:wikidata_label) { 'label' }
      let(:additional_params) { { add_external_topic: add_external_topic, wikidata_label: wikidata_label } }

      it 'creates record' do
        expect { expect(request).to be_successful }.to change { Aboutness.where(work: work).count }.by(1)
        expect(aboutness).to have_attributes(work: work, aboutable: nil, user: suggested_by_user, wikidata_qid: 12345, wikidata_label: wikidata_label)
      end
    end
  end
end
