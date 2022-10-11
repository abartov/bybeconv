class ResetDonationBannerSuppression < ActiveRecord::Migration[5.2]
  def change
    print "resetting donation banner suppression property... "
    BaseUserPreference.where(name: 'suppress_donation_banner').update_all(value: 0)
    puts "done!"
  end
end
