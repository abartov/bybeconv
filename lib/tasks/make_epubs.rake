require 'gepub'
require 'htmlentities'
require 'rmagick'

desc "Make ebooks for all authors"
task :make_ebooks => :environment do
  coder = HTMLEntities.new

  dirs = HtmlDir.all
  total = dirs.length
  i = 1
  dl_toc = []
  dirs.each {|dir|
    author = dir.author

    book = GEPUB::Book.new
    book.set_main_id('http://benyehuda.org/ebook/'+dir.path+'/all', 'BookID', 'URL')
    book.language = 'he'

    book.add_title('כתבי '+dir.author, nil, GEPUB::TITLE_TYPE::MAIN)
    book.add_creator(dir.author)
    book.page_progression_direction = 'rtl' # Hebrew! :)
    puts "processing dir: #{dir.path} #{i}/#{total}"
    files = HtmlFile.where("path like '%/#{dir.path}/%'").order('seqno asc')
    if files.length > 0
      # make cover image
      canvas = Magick::Image.new(1200, 800){self.background_color = 'white'}
      gc = Magick::Draw.new
      gc.gravity = Magick::CenterGravity
      gc.pointsize(50)
      gc.font('David CLM')
      gc.text(0,0,"כתבי #{dir.author}".reverse.center(50))
      gc.draw(canvas)
      gc.pointsize(30)
      gc.text(0,150,"פרי עמלם של מתנדבי פרויקט בן־יהודה".reverse.center(50))
      gc.pointsize(20)
      gc.text(0,250,Date.today.to_s+"מעודכן לתאריך: ".reverse.center(50))
      gc.draw(canvas)
      covername = Rails.configuration.constants['base_dir']+"/#{dir.path}/cover.jpg"
      canvas.write(covername)
      tmphtmldir = "/tmp/#{dir.path}" # temp dir for HTMLs to be converted into PDF later
      `mkdir -p #{tmphtmldir}`
      `rm -rf #{tmphtmldir}/*` # clean up any remains
      book.add_item('cover.jpg',covername).cover_image
      book.ordered {
        buf = '<head><meta charset="UTF-8"><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body dir="rtl" align="center"><h1>כתבי '+dir.author+'</h1><p/><p/><h3>פרי עמלם של מתנדבי</h3><p/><h2>פרויקט בן־יהודה</h2><p/><h3><a href="http://benyehuda.org/blog/%D7%A8%D7%95%D7%A6%D7%99%D7%9D-%D7%9C%D7%A2%D7%96%D7%95%D7%A8">(רוצים לעזור?)</a></h3><p/>מעודכן לתאריך: '+Date.today.to_s+'</body>'
        book.add_item('0_title.html').add_content(StringIO.new(buf))
        File.open(tmphtmldir + '/000_title.html','w') {|f| f.write(buf)} # write title page for PDF
        fileno = 1
        files.each {|f|
          begin
            buf = remove_payload(File.open(f.path).read) # remove donation banner and proof/recommend buttons
            buf = remove_toc_links(buf) # remove index and homepage links
            buf = remove_prose_table(buf)
            buf = coder.decode(buf)
            title = coder.decode(HtmlFile.title_from_file(f.path)[0].strip)
            book.add_item(f.url[1..-1]).add_content(StringIO.new(buf)).toc_text(title)
            File.open("#{tmphtmldir}/"+ "%03d" % fileno + '.html', 'w') {|f| f.write(buf)}
            fileno += 1
          rescue
            puts "! ERROR processing file #{f.path}!"
          end
        }
      }
      puts "writing epub..."
      fname = Rails.configuration.constants['base_dir']+"/#{dir.path}/#{dir.path}"
      book.generate_epub(fname + '.epub')
      puts "converting #{i} HTML files to PDF..."
      out = `wkhtmltopdf #{tmphtmldir}/*.html #{fname}.pdf` # NOTE: this relies on the static wkhtmltopdf built against patched Qt to work.  Available here: http://wkhtmltopdf.org/downloads.html
      # proceed to convert the EPUB to a MOBI too.  Assumes 'kindlegen' is in the system path.
      puts "converting EPUB to MOBI..."
      out = `kindlegen #{fname}.epub -c1 -o #{dir.path}.mobi`
      puts "done"
      dl_toc << "<li>#{dir.author}: <a href=\"/#{dir.path}/#{dir.path}.epub\">EPUB</a>, <a href=\"/#{dir.path}/#{dir.path}.mobi\">MOBI</a>, <a href=\"/#{dir.path}/#{dir.path}.pdf\">PDF</a></li>"
    else
      puts "skipping ebook for dir with no HtmlFiles"
    end
    i += 1
  }
  dl_toc.sort!
  File.open(Rails.configuration.constants['base_dir']+"/ebooks.html","w") {|f| f.write("<html><head><meta charset=\"UTF-8\"></head><body dir=\"rtl\" align=\"right\"><h1>פרויקט בן־יהודה</h1><h2>ספרים אלקטרוניים להורדה</h2><p/><p>בחרו יוצר להלן, ולחצו על תבנית הקובץ הרצויה. (עבור קינדל, בחרו MOBI)</p><p/><ol>"+dl_toc.join("\n")+"</ol><p/><p>בשאלות, כתבו אלינו: <a href=\"mailto:editor@benyehuda.org\">editor@benyehuda.org</a></p><hr><a href=\"/\">חזרה לדף הבית</a></body></html>")}
end

private

