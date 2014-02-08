require 'hebrew'
require 'action_view'

include ActionView::Helpers::SanitizeHelper

desc "Export the entire text database to plaintext"
task :mass_export, [:to_path] => :environment do |taskname, args|
  unless args.to_path.nil?
    txtcp_path = Dir.mkdir(args.to_path+'/txt_cp1255')
    txtu8_path = Dir.mkdir(args.to_path+'/txt_utf8')
    txtcp_stripped_path = Dir.mkdir(args.to_path+'/stripped_cp1255')
    txtu8_stripped_path = Dir.mkdir(args.to_path+'/stripped_utf8')

    basedir =  AppConstants.base_dir # environment-sensitive constant
    tot = { :files => 0, :errors => 0 }
    files = HtmlFile.all
    tot[:todo] = files.length
    files.each {|f|
      begin
        html = File.open(f.path, 'r:windows-1255:utf-8').read
        plaintext = strip_tags(html)
        stripped = plaintext.strip_nikkud
        path_part = f.path.sub(basedir+'/','')
        newpath = "/#{path_part[0..path_part.index('.html')-1]}.txt"
        File.open(txtcp_path + newpath, 'w:windows-1255') {|w| w.write(plaintext) }
        File.open(txtcp_stripped_path + newpath, 'w:windows-1255') {|w| w.write(stripped) }
        File.open(txtu8__path + newpath, 'w:utf-8') {|w| w.write(plaintext) }
        File.open(txtu8_stripped_path + newpath, 'w:utf-8') {|w| w.write(stripped) }
        tot[:files] += 1
      rescue IOError => e
        tot[:errors] += 1
        puts "\nerror: #{e.message} file: #{f.path}"
      end
      print "\r#{tot[:files]} files processed. #{tot[:files].to_f/tot[:todo]*100}% done.     " if tot[:files] % 25 == 0
    }

    print "\n#{tot[:files]} files processed; #{tot[:errors]} errors encountered.\n"
  else
    puts "please specify the path to output to (no trailing slash; existing files may be overwritten).\ne.g. rake mass_export[/home/xyzzy/corpus]"
  end
end

private 


