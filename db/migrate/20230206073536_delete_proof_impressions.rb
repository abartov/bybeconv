class DeleteProofImpressions < ActiveRecord::Migration[5.2]
  def change
    print "Deleting Proof impressions... "
    Impression.where(impressionable_type: 'Proof').delete_all
    puts "done!"
  end
end
