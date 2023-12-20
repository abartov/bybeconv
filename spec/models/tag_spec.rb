require 'rails_helper'

describe Tag do
  it "considers invalid an empty tag" do
    t = Tag.new
    expect(t).to_not be_valid
  end

  it 'considers valid tag with minimal attributes set' do
    t = Tag.new(name: Faker::Science.science, creator: create(:user), status: 'pending')
    expect(t).to be_valid
  end

  it 'has a valid factory' do
    expect(build(:tag)).to be_valid
  end

  it 'finds tags by creator' do
    u = create(:user)
    i = 0
    3.times do
      t = Tag.new(name: "#{Faker::Science.science} #{i.to_s} #{rand(1000)}", creator: u, status: 'pending')
      t.save
      i += 1
    end
    2.times do
      t = Tag.new(name: "#{Faker::Science.science} #{i.to_s} #{rand(1000)}", creator: create(:user), status: 'pending')
      t.save
      i += 1
    end
    expect(Tag.by_user(u).count).to eq 3
  end

  it 'fetches only approved tags' do
    u = create(:user)
    i = 0
    5.times do
      t = Tag.new(name: "#{Faker::Science.science} #{i.to_s} #{rand(1000)}", creator: u, status: 'pending')
      t.save
      i += 1
    end
    u2 = create(:user)
    Tag.last(2).each do |tag|
      tag.approve!(u2)
    end
    expect(Tag.approved.count).to eq 2
  end

  it 'fetches only pending tags' do
    u = create(:user)
    i = 0
    5.times do
      t = Tag.new(name: "#{Faker::Science.science} #{i.to_s} #{rand(1000)}", creator: u, status: 'pending')
      t.save
      i += 1
    end
    u2 = create(:user)
    Tag.last(2).each do |tag|
      tag.approve!(u2)
    end
    expect(Tag.pending.count).to eq 3
  end

  it 'approves a tag' do
    t = Tag.create!(name: Faker::Science.science, creator: create(:user), status: 'pending')
    expect(Tag.last.status).to eq 'pending'
    u = create(:user)
    t.approve!(u)
    expect(Tag.last.status).to eq 'approved'
  end

  it 'rejects and blacklists a tag' do
    t = Tag.create!(name: Faker::Science.science, creator: create(:user), status: 'pending')
    expect(Tag.last.status).to eq 'pending'
    u = create(:user)
    t.reject!(u)
    expect(Tag.last.status).to eq 'rejected'
  end

  it 'links to tagged manifestation via approved taggings' do
    t = Tag.create!(name: Faker::Science.science, creator: create(:user), status: 'approved')
    5.times do 
      Tagging.create!(tag: t, taggable: create(:manifestation), suggester: create(:user), status: 'approved')
    end
    t2 = Tag.create!(name: Faker::Science.science+' 2', creator: create(:user), status: 'approved')
    5.times do
      Tagging.create!(tag: t2, taggable: create(:manifestation), suggester: create(:user), status: 'pending')
    end
    expect(Tagging.all.count).to eq 10
    expect(t.taggings.count).to eq 5
    expect(t.manifestation_taggings.count).to eq 5
    expect(t2.taggings.count).to eq 5
    expect(t2.manifestation_taggings.count).to eq 5
    expect(t2.manifestation_taggings.approved.count).to eq 0
  end
  it 'links to tagged items of all kinds via approved taggings' do
    t = Tag.create!(name: Faker::Science.science, creator: create(:user), status: 'approved')
    5.times do 
      Tagging.create!(tag: t, taggable: create(:manifestation), suggester: create(:user), status: 'approved')
    end
    t2 = Tag.create!(name: Faker::Science.science+' 2', creator: create(:user), status: 'approved')
    5.times do
      Tagging.create!(tag: t, taggable: create(:manifestation), suggester: create(:user), status: 'pending')
    end
    5.times do
      Tagging.create!(tag: t, taggable: create(:person), suggester: create(:user), status: 'approved')
    end
    3.times do
      Tagging.create!(tag: t, taggable: create(:person), suggester: create(:user), status: 'pending')
    end
    5.times do
      Tagging.create!(tag: t2, taggable: create(:manifestation), suggester: create(:user), status: 'pending')
    end
    expect(Tagging.all.count).to eq 23
    expect(t.taggings.count).to eq 18
    expect(t.manifestation_taggings.count).to eq 10
    expect(t.people_taggings.count).to eq 8
    expect(t.people_taggings.approved.count).to eq 5
    expect(t.taggings.approved.count).to eq 10
    expect(t.manifestation_taggings.approved.count).to eq 5
    expect(t2.taggings.count).to eq 5
    expect(t2.manifestation_taggings.count).to eq 5
    expect(t2.manifestation_taggings.approved.count).to eq 0
  end

  it 'deletes taggings when tag is deleted' do
    t = Tag.create!(name: "#{Faker::Science.science} #{rand(1000)}", creator: create(:user), status: 'approved')
    5.times do 
      Tagging.create!(tag: t, taggable: create(:manifestation), suggester: create(:user), status: 'pending')
    end
    expect(Tag.last.taggings.count).to eq 5
    t.destroy
    expect(Tagging.count).to eq 0
  end
  it 'finds tags by TagName' do
    u = create(:user)
    i = 0
    5.times do
      t = Tag.new(name: "#{Faker::Science.science} #{i.to_s} #{rand(1000)}", creator: u, status: 'pending')
      t.save
      i += 1
    end
    t = Tag.last
    tn = t.name + '_alias'
    TagName.create!(name: tn, tag: t)
    expect(TagName.last.tag).to eq t
    expect(TagName.last.name).to eq tn
    expect(TagName.where(name: tn).count).to eq 1
    expect(TagName.where(name: t.name).count).to eq 1
  end
  it 'merges tag into another tag, including tag_names and taggings' do
    i = 0
    t = Tag.create!(name: Faker::Science.science+i.to_s, creator: create(:user), status: 'approved')
    5.times do 
      Tagging.create!(tag: t, taggable: create(:manifestation), suggester: create(:user), status: 'pending')
      TagName.create!(name: "#{Faker::Science.science} #{i*10}", tag: t)
      i += 1
    end
    expect(Tag.last.taggings.count).to eq 5
    expect(Tag.last.tag_names.count).to eq 6 # including one created upon tag creation
    t2 = Tag.create!(name: Faker::Science.science+i.to_s, creator: create(:user), status: 'approved')
    5.times do
      Tagging.create!(tag: t2, taggable: create(:manifestation), suggester: create(:user), status: 'pending')
      TagName.create!(name: "#{Faker::Science.science} #{i*10}", tag: t)
      i += 1
    end
    expect(Tagging.count).to eq 10
    expect(TagName.count).to eq 12
    tid = t.id
    t.merge_into(t2)
    expect(Tag.find_by(id: tid)).to be_nil # should be destroyed by the merge
    expect(Tag.count).to eq 1
    expect(t2.taggings.count).to eq 10
    expect(t2.tag_names.count).to eq 12
  end

end
