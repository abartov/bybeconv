desc "Create the 'what's new?' table as an HTML fragment to be pasted into the site's (static) main page"
task :whatsnew, [:fromdate] => :environment do |taskname, args|
  args.with_defaults(:fromdate => Date.today-30.days)
  print "args.fromdate seems to be #{args.fromdate}\n"

  thedir = AppConstants.base_dir # environment-sensitive constant
  tot = { :dir => 0, :files => 0, :new => 0, :upd => 0 }
  newfiles = HtmlFile.new_since(Date.new(args.fromdate))
  
  print "\n#{newfiles.count} new files found since #{args.fromdate}.\n"
end

private 

