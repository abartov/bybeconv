require 'hebrew'
require 'action_view'
require 'fileutils'
require 'htmlentities'
require 'csv'

include ActionView::Helpers::SanitizeHelper

desc "Export the entire text database to plaintext"
task :mass_export, [:to_path] => :environment do |taskname, args|
  unless args.to_path.nil?
    dumps = { :pd => Manifestation.pd, :nonpd => Manifestation.copyrighted}
    dumps.each_key do |dump|
      to_path = args.to_path+'/'+dump.to_s
      txt_path = to_path+'/txt'
      html_path = to_path+'/html'
      txt_stripped_path = to_path+'/txt_stripped'
      tot = { :works => 0, :errors => 0 }
      works = dumps[dump]
      tot[:todo] = works.length
      coder = HTMLEntities.new
      pseudocatalogue = []
      works.each {|m|
        begin
          ppath = "/p#{m.expressions[0].translation ? m.expressions[0].translators[0].id : m.expressions[0].works[0].authors[0].id}"
          fname = "/m#{m.id}"
          print "\r#{tot[:works]} files processed. #{(tot[:works].to_f/tot[:todo]).round(5)*100}% done.     " if tot[:works] % 10 == 0
          html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"he\" lang=\"he\" dir=\"rtl\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head><body dir='rtl' align='right'><div dir=\"rtl\" align=\"right\">"+MultiMarkdown.new(m.markdown_with_metadata).to_html.force_encoding('UTF-8')+"\n\n<hr />"+I18n.t(:download_footer_html, url: "https://bybe.benyehuda.org/read/#{m.id}")+"</div></body></html>"
          # prepare output buffers
          plaintext = html2txt(html)
          stripped = plaintext.strip_nikkud
          [txt_path, html_path, txt_stripped_path].each {|d|
            dname = d+ppath
            FileUtils.mkdir_p(dname) unless Dir.exists?(dname)
          }
          # dump works
          File.open(txt_path+ppath+fname+'.txt', 'w:utf-8'){|f| f.write(plaintext)}
          File.open(txt_stripped_path + ppath + fname+'.txt', 'w:utf-8') {|f| f.write(stripped) }
          File.open(html_path + ppath + fname+'.html', 'w:utf-8') {|f| f.write(html)}
          pseudocatalogue << [m.id, ppath+fname, m.title, m.expressions[0].works[0].authors.map{|x| x.name}.join('; '), m.expressions[0].translation ? m.expressions[0].translators.map{|x| x.name}.join('; ') : '', m.expressions[0].translation ? m.expressions[0].works[0].orig_lang : '', I18n.t(m.expressions[0].genre), m.expressions[0].source_edition || '']
          tot[:works] += 1
        rescue StandardError => e
          tot[:errors] += 1
          puts "\nerror: #{e.message} work: #{m.id} - #{m.title} - #{m.author_string}"
        end
      }
      File.open(to_path+'/pseudocatalogue.csv','w:utf-8'){|f|
        f.puts "ID,path,title,authors,translators,original_language,genre,source_edition"
        f.puts pseudocatalogue.map{|line| line.to_csv}.join
      }
      print "\n#{tot[:works]} files processed; #{tot[:errors]} errors encountered.\n"
    end
  else
    puts "please specify the path to output to (no trailing slash; existing works may be overwritten).\ne.g. rake mass_export[/home/xyzzy/corpus]"
  end
end

private

