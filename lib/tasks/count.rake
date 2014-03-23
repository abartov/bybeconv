desc "Count files and words in entire collection or in a given directory"
task :count, [:dir] => :environment do |taskname, args|
  args.with_defaults(:dir => '')
  print "Counting files and words in "
  if args.dir == '' 
    target_dir = "entire catalogue..."
    puts target_dir
    files = HtmlFile.all
  else
    target_dir = "directory '#{args.dir}'..."
    puts target_dir
    files = HtmlFile.find(:all, :conditions => "path like '%/#{args.dir}/%'")
  end
  puts "Found #{files.length} files."
  done = 0
  total_words = 0
  files.each {|html|
    begin
      slurp = File.open(html.path, 'rb').read
      slurp.gsub!(/<.*?>/m,' ')
      total_words += slurp.split.length
    rescue
      puts "warning: #{html.path} not found!"
    end
    done += 1
    puts "#{done} files done" if done % 100 == 0
  }
  s = "#{total_words} total words in #{files.length} files found in #{target_dir}"
  puts s
  File.open('count_task_output.txt','w') {|f| f.puts(s) }
end

