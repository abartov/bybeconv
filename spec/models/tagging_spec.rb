# frozen_string_literal: true

require 'rails_helper'

describe Tagging do
  it "considers invalid an empty tagging" do
    t = Tagging.new
    expect(t).to_not be_valid
  end

  it 'considers valid a tagging with minimal attributes set' do
    t = Tagging.new(tag: build(:tag), taggable: create(:manifestation), suggester: create(:user), status: 'pending')
    expect(t).to be_valid
  end

  it 'has a valid factory' do
    expect(build(:tagging)).to be_valid
  end

  it 'finds taggings by suggester' do
    u = create(:user)
    tag = build(:tag)
    3.times do
      Tagging.create!(tag: tag, suggester: u, status: 'pending', taggable: build(:manifestation))
    end
    2.times do
      Tagging.create!(tag: tag, suggester: create(:user), status: 'pending', taggable: build(:manifestation))
    end
    expect(Tagging.by_suggester(u).count).to eq 3
  end

  it 'fetches only approved taggings' do
    u = create(:user)
    5.times do
      tag = build(:tag)
      Tagging.create!(tag: build(:tag), suggester: u, status: 'pending', taggable: build(:manifestation))
    end
    3.times do
      Tagging.create!(tag: build(:tag), suggester: u, status: 'approved', taggable: build(:manifestation))
    end
    2.times do
      Tagging.create!(tag: build(:tag), suggester: u, status: 'rejected', taggable: build(:manifestation))
    end
    expect(Tagging.approved.count).to eq 3
  end

  it 'fetches only pending tags' do
    u = create(:user)
    5.times do
      Tagging.create!(tag: build(:tag), suggester: u, status: 'pending', taggable: build(:manifestation))
    end
    3.times do
      Tagging.create!(tag: build(:tag), suggester: u, status: 'approved', taggable: build(:manifestation))
    end
    2.times do
      Tagging.create!(tag: build(:tag), suggester: u, status: 'rejected', taggable: build(:manifestation))
    end
    expect(Tagging.pending.count).to eq 5
  end

  it 'approves a tagging' do
    u = create(:user)
    t = Tagging.create!(tag: build(:tag), suggester: create(:user), status: 'pending', taggable: build(:manifestation))
    expect(Tagging.last.status).to eq 'pending'
    t.approve!(u)
    expect(Tagging.last.status).to eq 'approved'
    expect(Tagging.last.approved_by).to eq u.id
  end

  it 'rejects and blacklists a tag' do
    u = create(:user)
    t = Tagging.create!(tag: build(:tag), suggester: create(:user), status: 'pending', taggable: build(:manifestation))
    expect(Tagging.last.status).to eq 'pending'
    t.reject!(u)
    expect(Tagging.last.status).to eq 'rejected'
    expect(Tagging.last.approved_by).to eq u.id
  end

  it 'gets tags for manifestation via taggings' do
    m = create(:manifestation)
    5.times do
      Tagging.create!(tag: build(:tag), suggester: create(:user), status: 'approved', taggable: m)
    end
    expect(m.tags.count).to eq 5
    3.times do
      Tagging.create!(tag: build(:tag), suggester: create(:user), status: 'approved', taggable: build(:manifestation))
    end
    m2 = Manifestation.find(m.id)
    expect(m2.tags.count).to eq 5
    expect(m2.taggings.count).to eq 5
  end

  describe '.destroy' do
    subject(:destroy) { tagging.destroy }

    let!(:tagging) { create(:tagging) }

    it 'deletes tagging but not tag or manifestation' do
      expect { destroy }.to change(described_class, :count).by(-1)
                                                           .and not_change(Tag, :count)
                                                           .and not_change(Manifestation, :count)
    end
  end

end
