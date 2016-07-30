require 'gepub'
require 'htmlentities'
require 'RMagick'

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
    book.page_progression_direction = 'rtl' # Hebrew! :)
    puts "processing dir: #{dir.path}"
    files = HtmlFile.where("path like '%/#{dir.path}/%'").order('seqno asc')
    if files.length > 0
      # make cover image
      canvas = Magick::Image.new(1200, 800){self.background_color = 'white'}
      gc = Magick::Draw.new
      gc.gravity = Magick::CenterGravity
      gc.pointsize(50)
      gc.text(0,0,"כתבי #{dir.author}".reverse.center(50))
      gc.draw(canvas)
      gc.pointsize(30)
      gc.text(0,150,"פרי עמלם של מתנדבי פרויקט בן-יהודה".reverse.center(50))
      gc.pointsize(20)
      gc.text(0,250,Date.today.to_s+"מעודכן לתאריך: ".reverse.center(50))
      gc.draw(canvas)
      covername = AppConstants.base_dir+"/#{dir.path}/cover.jpg"
      canvas.write(covername)
      book.add_item('cover.jpg',covername).cover_image
      book.ordered {
        book.add_item('0_title.html').add_content(StringIO.new('<head><meta charset="UTF-8"><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body dir="rtl" align="center"><h1>כתבי '+dir.author+'</h1><p/><p/><h2>פרי עמלם של מתנדבי פרויקט בן-יהודה</h2><p/><h3><a href="http://benyehuda.org/blog/%D7%A8%D7%95%D7%A6%D7%99%D7%9D-%D7%9C%D7%A2%D7%96%D7%95%D7%A8">(רוצים לעזור?)</a></h3><p/>מעודכן לתאריך: '+Date.today.to_s+'</body>'))
        files.each {|f| 
          buf = remove_payload(File.open(f.path).read) # remove donation banner and proof/recommend buttons
          buf = remove_toc_links(buf) # remove index and homepage links
          book.add_item(f.url[1..-1]).add_content(StringIO.new(coder.decode(buf))).toc_text(coder.decode(HtmlFile.title_from_file(f.path)[0].strip))
        }
      }
      puts "writing epub..."
      fname = AppConstants.base_dir+"/#{dir.path}/#{dir.path}"
      book.generate_epub(fname + '.epub')
      # proceed to convert the EPUB to a MOBI too.  Assumes 'kindlegen' is in the system path.
      puts "converting EPUB to MOBI..."
      out = `kindlegen #{fname}.epub -c1 -verbose  -o #{dir.path}.mobi`
      puts(out)
      puts "done"
    else
      puts "skipping ebook for dir with no HtmlFiles"
    end
  }

end

private 

