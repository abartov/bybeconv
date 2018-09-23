require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user creation (invalid empty)" do
    u = User.new
    assert_not u.save
  end
  test "user creation (invalid email)" do
    u = User.new(name: 'asaf', email: 'test1', provider: 'developer')
    assert_not u.save
  end
  test "user creation (duplicate email)" do
    u = User.new(name: 'asaf', email: 'test1@benyehuda.org', provider: 'developer')
    assert u.save
    u2 = User.new(name: 'asaf', email: 'test1@benyehuda.org')
    assert_not u2.save
    assert u.destroy!
  end
  test "user email change" do
    u = users(:a_user)
    old_em = u.email
    u.email = 'some_new_invalid_value'
    assert_not u.save
    u.email = 'new_valid_email@benyehuda.org'
    assert u.save
    u.email = old_em
    assert u.save
    u.email = users(:an_editor).email # dupe!
    assert_not u.save
  end
  test "editor_bits" do
    u = User.new(name: 'asaf', email: 'test1@benyehuda.org', provider: 'developer', editor: true)
    assert u.save
    assert_not u.has_bit?('test_bit')
    li = ListItem.new(listkey: 'test_bit', item: u)
    li.save!
    assert u.has_bit?('test_bit')
    assert_not u.has_bit?('other_bit')
    li = ListItem.where(listkey: 'test_bit', item: u).first
    assert li.destroy!
    assert_not u.has_bit?('test_bit')
    assert u.destroy!
    u = users(:a_user)
    assert_not u.has_bit?('test_bit')
  end

  # TODO: test properties, liked works, recommendations, taggings
end
