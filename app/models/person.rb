include BybeUtils
class Person < ActiveRecord::Base
  attr_accessible :affiliation, :comment, :country, :dates, :name, :nli_id, :other_designation, :title, :viaf_id

  belongs_to :toc
  has_and_belongs_to_many :work
  has_and_belongs_to_many :expression
  has_and_belongs_to_many :manifestation

  def self.person_by_viaf(viaf_id)
    Person.find_by_viaf_id(viaf_id)
  end
  def self.create_or_get_person_by_viaf(viaf_id)
    p = Person.person_by_viaf(viaf_id)
    if p.nil?
      viaf_record = viaf_record_by_id(viaf_id)
      fail Exception if viaf_record.nil?
      #debugger
      p = Person.new(dates: "#{viaf_record['birthDate'].encode('utf-8')}-#{viaf_record['deathDate'].encode('utf-8')}", name: viaf_record['labels'][0].encode('utf-8'), viaf_id: viaf_id)
      p.save!
    end
    p
  end
end
