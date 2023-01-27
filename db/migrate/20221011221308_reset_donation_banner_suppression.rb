class ResetDonationBannerSuppression < ActiveRecord::Migration[5.2]
  def change
    print "resetting donation banner suppression property... "
    ActiveRecord::Base.connection.execute(
      "UPDATE base_user_preferences SET value = 0 WHERE name = 'suppress_donation_banner'"
    )
    puts "done!"
  end
end
