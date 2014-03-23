require 'hebrew'

desc "Create versions stripped of nikkud for search engines"
task :strip_nikkud => :environment do
  basedir =  AppConstants.base_dir # environment-sensitive constant
  tot = { :files => 0, :stripped => 0, :errors => 0 }
  the_insert = File.open(AppConstants.no_nikkud_insert, 'r:windows-1255').read
  files = HtmlFile.with_nikkud.not_stripped
  files.each {|f|
    # TODO: create a separate file ending with _no_nikkud, with a link/redirect to the actual file
    print f.path + ' --> '
    begin
      html = File.open(f.path, 'r:windows-1255').read
      stripped = html.strip_nikkud
      # add notice for humans
      url = f.path[f.path.rindex('/')+1..-1]
      subbed = the_insert.sub('$ACTUAL_URL$', url)
      stripped.match /(<body[^>]*>)(.*)<\/body>/m
      stripped = $` + $1 + subbed + $2 + '</body>' + $'
      newpath = f.path[0..f.path.index('.html')-1] + '_no_nikkud.html'
      
      File.open(newpath, 'w:windows-1255') {|out| out.write(stripped) }
      f.stripped_nikkud = true
      f.save!
      puts newpath
      tot[:stripped] += 1
    rescue IOError => e
      tot[:errors] += 1
      puts "error: #{e.message}"
    end
  }
  print "\n##{files.length} files with nikkud processed: #{tot[:stripped]} no-nikkud versions created/updated, #{tot[:errors]} errors encountered.\n"
end

private 


