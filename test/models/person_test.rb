require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "person creation (invalid empty)" do
    p = Person.new
    assert_not p.save
  end
  test "person creation (field combinations)" do
    p = Person.new(name: 'asaf') # minimal field
    assert p.save
    p = Person.new(name: 'asaf', country: 'Israel', deathdate: '28 מארס 1923', wikipedia_url: 'https://he.wikipedia.org/wiki/אסף_ברטוב') # other fields; name can be duplicate
    assert p.save
    assert p.destroy
  end
  test "person updates" do
    p = people(:author1)
    old_c = p.country
    p.country = 'Ruritania'
    assert p.save
    p.country = old_c
    assert p.save
    old_n = p.name
    p.name = nil
    assert_not p.save
  end

  # TODO: test scopes, relations, methods, class methods...
end
