# frozen_string_literal: true

module V1
  module Entities
    # API representation for Person objects
    class Person < Grape::Entity
      expose :gender, documentation: { values: ::Person.genders.keys }
      expose :period, documentation: { values: ::Person.periods.keys }
      expose :birth_year, documentation: { type: 'Integer' }
      expose :death_year, documentation: { type: 'Integer' }
    end
  end
end
