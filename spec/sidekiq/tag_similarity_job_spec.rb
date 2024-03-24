require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake! # fake is the default mode

RSpec.describe TagSimilarityJob, type: :job do
  it 'reports similar tags' do
    u = create(:user)
    t = Tag.new(name: "test1", creator: u, status: 'approved')
    t.save # a TagName is created as well
    t2 = Tag.new(name: "test2", creator: u, status: 'pending')
    t2.save
    job = TagSimilarityJob.new
    job.perform(t2.id) # find similar tags
    expect(ListItem.where(listkey: 'tag_similarity', item: t2).count).to eq 1
    expect(ListItem.where(listkey: 'tag_similarity', item: t2).first.extra).to eq "80%:#{t.id}"
  end
  it 'enqueues a job' do
    u = create(:user)
    t = Tag.new(name: "test1", creator: u, status: 'approved')
    t.save # a TagName is created as well
    t2 = Tag.new(name: "test2", creator: u, status: 'pending')
    t2.save
    expect { TagSimilarityJob.perform_async(t2.id) }.to change(TagSimilarityJob.jobs, :size).by(1) # schedule a job to find similar tags
  end
  it 'does not report dissimilar tags' do
    u = create(:user)
    t = Tag.new(name: "test1", creator: u, status: 'approved')
    t.save # a TagName is created as well
    t2 = Tag.new(name: "absolutely-different-tag", creator: u, status: 'pending')
    t2.save
    job = TagSimilarityJob.new
    job.perform(t2.id) # find similar tags
    expect(ListItem.where(listkey: 'tag_similarity', item: t2).count).to eq 0
  end
end
