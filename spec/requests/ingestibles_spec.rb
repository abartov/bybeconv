# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/ingestibles' do
  # Ingestible. As you add validations to Ingestible, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Ingestible.create! valid_attributes
      get ingestibles_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      ingestible = Ingestible.create! valid_attributes
      get ingestible_url(ingestible)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_ingestible_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      ingestible = Ingestible.create! valid_attributes
      get edit_ingestible_url(ingestible)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Ingestible' do
        expect do
          post ingestibles_url, params: { ingestible: valid_attributes }
        end.to change(Ingestible, :count).by(1)
      end

      it 'redirects to the created ingestible' do
        post ingestibles_url, params: { ingestible: valid_attributes }
        expect(response).to redirect_to(ingestible_url(Ingestible.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Ingestible' do
        expect do
          post ingestibles_url, params: { ingestible: invalid_attributes }
        end.not_to change(Ingestible, :count)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post ingestibles_url, params: { ingestible: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        skip('Add a hash of attributes valid for your model')
      end

      it 'updates the requested ingestible' do
        ingestible = Ingestible.create! valid_attributes
        patch ingestible_url(ingestible), params: { ingestible: new_attributes }
        ingestible.reload
        skip('Add assertions for updated state')
      end

      it 'redirects to the ingestible' do
        ingestible = Ingestible.create! valid_attributes
        patch ingestible_url(ingestible), params: { ingestible: new_attributes }
        ingestible.reload
        expect(response).to redirect_to(ingestible_url(ingestible))
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        ingestible = Ingestible.create! valid_attributes
        patch ingestible_url(ingestible), params: { ingestible: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested ingestible' do
      ingestible = Ingestible.create! valid_attributes
      expect do
        delete ingestible_url(ingestible)
      end.to change(Ingestible, :count).by(-1)
    end

    it 'redirects to the ingestibles list' do
      ingestible = Ingestible.create! valid_attributes
      delete ingestible_url(ingestible)
      expect(response).to redirect_to(ingestibles_url)
    end
  end
end
