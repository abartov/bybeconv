require 'gepub'
require 'htmlentities'

desc "Make ebooks for all authors"
task :make_ebooks => :environment do
  coder = HTMLEntities.new

  dirs = HtmlDir.all
  dirs.each {|dir|
    author = dir.author

    book = GEPUB::Book.new
    book.set_main_id('http://benyehuda.org/ebook/'+dir.path+'/all', 'BookID', 'URL')
    book.language = 'he'
   
    book.add_title('כתבי '+dir.author, nil, GEPUB::TITLE_TYPE::MAIN) 
    book.add_creator(dir.author)
    puts "processing dir: #{dir.path}"
    files = HtmlFile.where("path like '%/#{dir.path}/%'").order('seqno asc')
    book.ordered {
      files.each {|f| 
        buf = remove_payload(File.open(f.path).read) # remove donation banner and proof/recommend buttons
        book.add_item(f.url).add_content(StringIO.new(coder.decode(buf))).toc_text(coder.decode(HtmlFile.title_from_file(f.path)[0].strip))
      }
    }
    if files.length > 0
      puts "writing epub..."
      book.generate_epub(AppConstants.base_dir+"/#{dir.path}/#{dir.path}.epub")
    else
      puts "skipping ebook for dir with no HtmlFiles"
    end
  }

end

private 

