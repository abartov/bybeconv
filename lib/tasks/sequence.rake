desc "Regenerate the sequence numbers for extant HtmlFiles according to current contents of the index.html files"
task :sequence => :environment do
  error = false
  HtmlDir.where(need_resequence: true).each {|d|
    # read respective index.html, build a hash of filenames and sequences
    puts "Processing dir: #{d.path}."
    index = File.open("#{AppConstants.base_dir}/#{d.path}/index.html", 'rb').read.gsub(/[\r\n]/,'') # slurp whole thing, lose newlines
    links = index.scan /[A-Za-z_0-9]*?\.html/
    links.uniq!
    linkhash = {}
    seqno = 1
    links.each {|l|
      linkhash[l] = seqno
      seqno += 1
    }
    # iterate over associated HtmlFiles, updating the seqno in each according to hash
    HtmlFile.of_dir(d.path).each {|h|
      seq = linkhash[h.filepart]
      if seq.nil?
        puts "ERROR: file #{h.filepart} not found in linkhash!"
        error = true
      else
        h.seqno = seq
        h.save!
      end
    }
    unless error 
      d.need_resequence = false
      d.save!
    end
  }
end

