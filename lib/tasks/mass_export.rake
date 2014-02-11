require 'hebrew'
require 'action_view'
require 'fileutils'

include ActionView::Helpers::SanitizeHelper

desc "Export the entire text database to plaintext"
task :mass_export, [:to_path] => :environment do |taskname, args|
  unless args.to_path.nil?
    txtcp_path = args.to_path+'/txt_cp1255'
    txtu8_path = args.to_path+'/txt_utf8'
    txtcp_stripped_path = args.to_path+'/stripped_cp1255'
    txtu8_stripped_path = args.to_path+'/stripped_utf8'
    basedir =  AppConstants.base_dir # environment-sensitive constant
    tot = { :files => 0, :errors => 0 }
    files = HtmlFile.all
    tot[:todo] = files.length
    files.each {|f|
      begin
        path_part = f.path.sub(basedir+'/','')
        print "\r#{path_part} - #{tot[:files]} files processed. #{tot[:files].to_f/tot[:todo]*100}% done.     " 
        html = File.open(f.path, 'r:windows-1255:utf-8').read # slurp input and convert to UTF-8
        # prepare output buffers
        plaintext = strip_tags(html)
        stripped = plaintext.strip_nikkud
        newpath = "/#{path_part[0..path_part.index('.html')-1]}.txt"
        # recursively mkdir to prepare place for files
        dirs = File.dirname(newpath) 
        [txtcp_path, txtu8_path, txtcp_stripped_path, txtu8_stripped_path].each {|d|
          FileUtils.mkdir_p d+dirs
        }

        # dump files
        File.open(txtcp_path + newpath, 'w:windows-1255') {|w| w.write(plaintext) }
        File.open(txtcp_stripped_path + newpath, 'w:windows-1255') {|w| w.write(stripped) }
        File.open(txtu8_path + newpath, 'w:utf-8') {|w| w.write(plaintext) }
        File.open(txtu8_stripped_path + newpath, 'w:utf-8') {|w| w.write(stripped) }
        tot[:files] += 1
      rescue IOError => e
        tot[:errors] += 1
        puts "\nerror: #{e.message} file: #{f.path}"
      end
    }

    print "\n#{tot[:files]} files processed; #{tot[:errors]} errors encountered.\n"
  else
    puts "please specify the path to output to (no trailing slash; existing files may be overwritten).\ne.g. rake mass_export[/home/xyzzy/corpus]"
  end
end

private 

