FactoryBot.define do
  factory :anthology do
    user { create(:user) }
    sequence( :title) { |n| "Anthology #{n}" }
    access { :priv }

    transient do
      manifestations { create_list(:manifestation, 1) }
    end

    after(:create) do |anthology, evaluator|
      evaluator.manifestations.each do |m|
        anthology.texts << create(:anthology_text, manifestation: m, anthology: anthology)
      end
      anthology.sequence = anthology.texts.map(&:id).join(';')
      anthology.save!
    end
  end
end
