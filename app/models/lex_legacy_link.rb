# frozen_string_literal: true

# Model used to map old lexicon links to new locations in Ben-Yehuda project
class LexLegacyLink < ApplicationRecord
  before_validation do
    self.old_path&.strip!
    self.old_path&.downcase!
    self.old_path.gsub!(/\Ahttp(s)?:\/\/(www\.)?benyehuda.org\/lexicon\//, '')
    self.old_path = old_path[1..] if old_path&.start_with?('/')
  end

  validate :old_path, :new_path, presence: true
end