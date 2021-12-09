def clean_tables
  Tagging.delete_all
  Tag.delete_all
  ExternalLink.delete_all
  Recommendation.delete_all

  Realizer.delete_all
  Creation.delete_all
  Person.delete_all

  Aboutness.delete_all

  Work.destroy_all
  Expression.destroy_all
  Manifestation.destroy_all

  # Cleaning-up ElasticSearch indices
  Chewy.massacre
end
