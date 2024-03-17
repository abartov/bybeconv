class TagSimilarityJob
  include Sidekiq::Job

  def perform(tag_id)
    tag = Tag.find(tag_id)
    TagName.pluck(:tag_id, :name).each do |tag_id, name|
      next if tag_id == tag.id
      idx = tag.tag_names.first.similar_to?(name) # returns false if not similar, or the similarity index if similar
      if idx
        ListItem.create!(listkey: 'tag_similarity', item: tag, extra: "#{idx}%:#{tag_id}")
      end
    end
  end
end
