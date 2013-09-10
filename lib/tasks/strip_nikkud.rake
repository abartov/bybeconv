require 'hebrew'

desc "Create versions stripped of nikkud for search engines"
task :strip_nikkud => :environment do
  basedir =  AppConstants.base_dir # environment-sensitive constant
  tot = { :files => 0, :stripped => 0, :errors => 0 }
  files = HtmlFile.with_nikkud.not_stripped
  files.each {|f|
    # TODO: create a separate file ending with _no_nikkud, with a link/redirect to the actual file
    puts f.path
  }
  print "\n##{tot[:files]} files with nikkud processed: #{tot[:stripped]} no-nikkud versions created/updated, #{tot[:errors]} errors encountered.\n"
end

private 


