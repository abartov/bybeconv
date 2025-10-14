require 'rails_helper'

describe ApplicationController do
  describe '.make_heading_ids_unique' do
    subject { @controller.make_heading_ids_unique(html) }

    context 'when HTML has headings with duplicate IDs' do
      let(:html) do
        <<~HTML
          <h2 id="chapter-1">Chapter 1</h2>
          <p>Content of first chapter 1</p>
          <h2 id="chapter-1">Chapter 1</h2>
          <p>Content of second chapter 1</p>
          <h3 id="section">Section</h3>
        HTML
      end

      it 'replaces IDs with unique sequential IDs' do
        result = subject
        # Extract all heading IDs
        heading_ids = result.scan(/<h[23][^>]*id="([^"]+)"/).flatten
        # Verify all IDs are unique
        expect(heading_ids.uniq.length).to eq(heading_ids.length)
        # Verify IDs follow the expected pattern
        expect(heading_ids).to match_array(['heading-1', 'heading-2', 'heading-3'])
        # Verify heading content is preserved
        expect(result).to include('Chapter 1')
        expect(result).to include('Section')
      end
    end

    context 'when HTML has no headings' do
      let(:html) { '<p>Just a paragraph</p>' }

      it 'returns the HTML unchanged' do
        expect(subject).to eq(html)
      end
    end
  end

  describe '.base_user' do
    subject { @controller.base_user }
    let!(:user) { create(:user) }

    context 'when user is not authenticated' do
      context 'when BaseUser with given session_id exists' do
        let!(:base_user) { create(:base_user, session_id: session.id.private_id) }

        it 'returns it' do
          expect { subject }.to_not change { BaseUser.count }
          expect(subject).to eq base_user
        end
      end

      context 'when no BaseUser record exists' do
        it { is_expected.to be_nil }

        context 'when force_create arg is provided' do
          subject { @controller.base_user(true) }

          it 'creates new one' do
            expect { subject }.to change { BaseUser.count }.by(1)
            bu = BaseUser.order(id: :desc).first
            expect(subject).to eq bu
            expect(bu.session_id).to eq session.id.private_id
            expect(bu.user).to be_nil
          end
        end
      end
    end

    context 'when user is authenticated' do
      before do
        session[:user_id] = user.id
      end

      context 'when BaseUser record with given user_id exists' do
        let!(:base_user) { create(:base_user, user: user) }

        it 'returns it' do
          expect { subject }.to_not change { BaseUser.count }
          expect(subject).to eq base_user
        end
      end

      context 'when no BaseUser record exists' do
        it { is_expected.to be_nil }

        context 'when force_create arg is provided' do
          subject { @controller.base_user(true) }
          it 'creates new one' do
            expect { subject }.to change { BaseUser.count }.by(1)
            bu = BaseUser.order(id: :desc).first
            expect(subject).to eq bu
            expect(bu.user_id).to eq user.id
            expect(bu.session_id).to be_nil
          end
        end
      end
    end
  end
end