def clean_tables
  Tagging.delete_all
  Tag.delete_all
  ExternalLink.delete_all
  Recommendation.delete_all

  Realizer.delete_all
  Creation.delete_all

  Person.delete_all

  Aboutness.delete_all

  ListItem.delete_all
  User.delete_all

  ActiveRecord::Base.connection.execute('delete from expressions_manifestations')
  ActiveRecord::Base.connection.execute('delete from expressions_works')

  Work.delete_all
  Expression.delete_all
  Manifestation.delete_all

  Publication.delete_all
  Holding.delete_all
  BibSource.delete_all

  # Cleaning-up ElasticSearch indices
  Chewy.massacre
end
