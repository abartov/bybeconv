# frozen_string_literal: true

require 'rails_helper'

describe HtmlFileController do
  include_context 'when editor logged in', :edit_catalog

  describe '#new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe '#create' do
    subject(:call) { post :create, params: { html_file: html_file_attributes } }

    let(:html_file_attributes) do
      attributes_for(:html_file, title: title).tap do |attrs|
        attrs[:author_id] = attrs.delete(:author).id
        attrs[:translator_id] = attrs.delete(:translator).id
      end
    end

    let(:created_html_file) { HtmlFile.order(id: :desc).first }

    context 'when attributes are valid' do
      let(:title) { Faker::Book.title }

      it 'creates a new html file' do
        expect { call }.to change(HtmlFile, :count).by(1)
        expect(call).to redirect_to html_file_edit_markdown_path(id: created_html_file)
      end
    end

    context 'when attributes are invalid' do
      let(:title) { nil }

      it 're-renders new form' do
        expect { call }.to not_change(HtmlFile, :count)
        expect(call).to render_template(:new)
      end
    end
  end

  describe 'Member actions' do
    let!(:html_file) { create(:html_file, :with_markdown) }

    describe '#edit_markdown' do
      subject { get :edit_markdown, params: { id: html_file.id } }

      it { is_expected.to be_successful }
    end
  end
end

