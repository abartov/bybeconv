require 'rails_helper'

describe AuthorsController do
  describe '#get_random_author' do
    before do
      create_list(:manifestation, 5)
      # For randomize_authors test we need to have bunch of authors with TOCs
      authors = Person.joins(:creations).merge(Creation.author).to_a
      authors.each do |author|
        toc = create(:toc)
        author.toc = toc
        author.save!
      end
    end

    %w(home gallery).each do |mode|
      context "when mode is '#{mode}'" do
        let(:mode) { home }
      end

      context 'when genre is not provided' do
        subject { get :get_random_author, params: { mode: mode } }
        it { is_expected.to be_successful }
      end

      context 'when genre provided' do
        let(:genre) { Work.first.genre }

        subject { get :get_random_author, params: { mode: mode, genre: genre } }
        it { is_expected.to be_successful }
      end
    end
  end

  describe '#toc' do
    let(:author) { create(:person) }

    before do
      create_list(:manifestation, 5, author: author)
    end

    subject(:request) { get :toc, params: { id: author.id } }

    it { is_expected.to be_successful }
  end

  describe '#whatsnew_popup' do
    let(:manifestation) { create(:manifestation, created_at: created_at) }
    let(:author) { manifestation.authors.first }

    subject { get :whatsnew_popup, params: { id: author.id } }

    context 'when there is a new work in last month' do
      let(:created_at) { 20.days.ago }
      it { is_expected.to be_successful }
    end

    context 'when there is no new works in last month' do
      let(:created_at) { 35.days.ago }
      it { is_expected.to be_successful }
    end
  end

  describe '#latest_popup' do
    let(:author) { create(:person) }
    subject { get :latest_popup, params: { id: author.id } }

    context 'when author has works' do
      before do
        create_list(:manifestation, 25, author: author)
      end
      it { is_expected.to be_successful }
    end

    context 'when there are no works' do
      it { is_expected.to be_successful }
    end
  end

  describe '#print' do
    let(:author) { create(:person) }
    subject { get :print, params: { id: author.id } }

    before do
      create(:manifestation, author: author)
      create(:manifestation, translator: author)
    end

    it { is_expected.to be_successful }
  end

  describe 'Editor actions' do
    let(:user) { create(:user, editor: true, admin: true) }

    before do
      create(:list_item, item: user, listkey: :edit_people)
      session[:user_id] = user.id
    end

    describe '#publish' do
      let(:author) { create(:person) }
      subject { get :publish, params: { id: author.id } }


      before do
        create_list(:manifestation, 3, author: author, status: :unpublished)
      end

      it { is_expected.to be_successful }
    end
  end
end
