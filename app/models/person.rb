include BybeUtils
class Person < ActiveRecord::Base
  def self.person_by_viaf(viaf_id)
    Person.find_by_viaf_id(viaf_id)
  end
  def self.create_or_get_person_by_viaf(viaf_id)
    p = Person.person_by_viaf(viaf_id)
    if p.nil?
      viaf_record = viaf_record_by_id(viaf_id)
      fail Exception if viaf_record.nil?
      #debugger
      p = Person.new(dates: "#{viaf_record['birthDate']}-#{viaf_record['deathDate']}", name: viaf_record['labels'][0], viaf_id: viaf_id)
      p.save!
    end
    p
  end
end
