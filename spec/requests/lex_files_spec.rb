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

RSpec.describe "/lex_files", type: :request do
  
  # LexFile. As you add validations to LexFile, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      LexFile.create! valid_attributes
      get lex_files_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      lex_file = LexFile.create! valid_attributes
      get lex_file_url(lex_file)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_lex_file_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      lex_file = LexFile.create! valid_attributes
      get edit_lex_file_url(lex_file)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new LexFile" do
        expect {
          post lex_files_url, params: { lex_file: valid_attributes }
        }.to change(LexFile, :count).by(1)
      end

      it "redirects to the created lex_file" do
        post lex_files_url, params: { lex_file: valid_attributes }
        expect(response).to redirect_to(lex_file_url(LexFile.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new LexFile" do
        expect {
          post lex_files_url, params: { lex_file: invalid_attributes }
        }.to change(LexFile, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post lex_files_url, params: { lex_file: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested lex_file" do
        lex_file = LexFile.create! valid_attributes
        patch lex_file_url(lex_file), params: { lex_file: new_attributes }
        lex_file.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the lex_file" do
        lex_file = LexFile.create! valid_attributes
        patch lex_file_url(lex_file), params: { lex_file: new_attributes }
        lex_file.reload
        expect(response).to redirect_to(lex_file_url(lex_file))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        lex_file = LexFile.create! valid_attributes
        patch lex_file_url(lex_file), params: { lex_file: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested lex_file" do
      lex_file = LexFile.create! valid_attributes
      expect {
        delete lex_file_url(lex_file)
      }.to change(LexFile, :count).by(-1)
    end

    it "redirects to the lex_files list" do
      lex_file = LexFile.create! valid_attributes
      delete lex_file_url(lex_file)
      expect(response).to redirect_to(lex_files_url)
    end
  end
end
