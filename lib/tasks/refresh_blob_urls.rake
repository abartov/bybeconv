desc "Refresh active storage blob URLs in markdown"
task :refresh_blob_urls => :environment do
  puts "Refreshing blob urls due to signed_id change..."
  mm_ids = ActiveStorage::Attachment.where(name: 'images', record_type: 'Manifestation').pluck(:record_id).uniq
  total = mm_ids.count
  i = 0
  replaced = 0
  missing_imgs = []
  Chewy.strategy(:atomic) do
    mm_ids.each do |mid|
      puts "Processing item #{i} of #{total}" if i % 50 == 0
      m = Manifestation.find(mid)
      m.markdown = m.markdown.gsub(/!\[.*?\]\(\/rails\/active_storage\/blobs\/.*\/(.*)\)/) do |match|
        img = m.images.joins(:blob).where(blob: {filename: $1}).first
        if img.present?
          replaced += 1
          "![#{$1}](#{Rails.application.routes.url_helpers.url_for(img).gsub('https://benyehuda.org','')})"
          # Rails.application.routes.url_helpers.rails_blob_path(img, only_path: true)
        else
          puts "missing image in mid #{mid}"
          missing_imgs << mid
          match
        end
      end
      m.save
      i += 1
    end
    puts "Done. Replaced #{replaced} image urls."
    puts "Missing images in #{missing_imgs.count} manifestations: #{missing_imgs.join(', ')}"
  end
end