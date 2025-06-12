desc "Regenerate the sequence numbers for extant HtmlFiles according to current contents of the index.html files"
task :sequence => :environment do
  HtmlDir.where(need_resequence: true).each {|d|
    error = false
    # read respective index.html, build a hash of filenames and sequences
    puts "Processing dir: #{d.path}."
    fname = "#{Rails.configuration.constants['base_dir']}/#{d.path}/index.html"
    next unless File.exists? fname
    index = File.open(fname, 'rb').read.gsub(/[\r\n]/,'') # slurp whole thing, lose newlines
    links = index.scan /[A-Za-z\-_0-9]*?\.html/
    if links.length == 0 # some index files are now UTF-16 because Word sucks
      index = File.open(fname, 'rb:UTF-16LE:UTF-8').read.gsub(/[\r\n]/,'')
      links = index.scan /[A-Za-z\-_0-9]*?\.html/
    end
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
        puts "ERROR: file #{d.path}/#{h.filepart} ID #{h.id} not found in linkhash!"
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
    puts "#{HtmlDir.where(need_resequence: true).count} to go"
    #break
  }
end

