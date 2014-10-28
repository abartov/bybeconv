require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  test "proof_fixed" do
    mail = Notifications.proof_fixed
    assert_equal "Proof fixed", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "proof_wontfix" do
    mail = Notifications.proof_wontfix
    assert_equal "Proof wontfix", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "recommendation_accepted" do
    mail = Notifications.recommendation_accepted
    assert_equal "Recommendation accepted", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "recommendation_blogged" do
    mail = Notifications.recommendation_blogged
    assert_equal "Recommendation blogged", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
