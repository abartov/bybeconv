# This model implements parsing and rendering down of icky fatty Microsoft-Word-generated HTML files into reasonable MultiMarkDown texts.  It makes no attempt at being general-purpose -- it is designed to mass-convert files from Project Ben-Yehuda (http://benyehuda.org), but it is hoped it would be easily adaptable to other mass-conversion efforts of Word-generated HTML files, with some tweaking of the regexps and the markdown generation. --abartov

require 'multimarkdown'

ENCODING_SUBSTS = [{ :from => "\xCA", :to => "\xC9" }, # fix weird invalid chars instead of proper Hebrew xolams
    { :from => "\xFC", :to => "&uuml;"}, # fix u-umlaut
    { :from => "\xFB", :to => "&ucirc;"},
    { :from => "\xFF", :to => "&yuml;"}] # fix u-circumflex


class NokoDoc < Nokogiri::XML::SAX::Document
  def initialize
    @markdown = ''
    @in_title = false
    @in_footnote = false
    @title = ''
    @anything = false
    @spans = [] # a span/style stack
    @links = [] # a links stack
    @footnotes = []
    @footnote = {}
    @post_processing_done = false
  end

  def push_style(style)
    @spans.push({:style => style, :markdown => '', :anything => false})
  end

  def start_element name, attributes
    #puts "found a #{name} with attributes: #{attributes}"
    if name == 'title' 
      @in_title = true
    elsif name == 'span'
      style_attr = attributes.assoc('style')
      style = {:decoration => []}
      unless style_attr.nil?
        # handle style=
        stylestr = style_attr[1]
        if m = /font-family:([^;\"]+)/i.match(stylestr)
          style[:font] = m[1]
        end
        if m = /font-size:(\d\d)\.0pt/i.match(stylestr)
          style[:size] = m[1] # $1
        end
        if m = /text-decoration:underline/i.match(stylestr)
          style[:decoration].push(:underline)
        end
        if m = /font-weight:bold/i.match(stylestr)
          style[:decoration].push(:bold)
        end
      end
      push_style(style)
    elsif name == 'b'
      push_style({:decoration => [:bold]})
    elsif name == 'u'
      push_style({:decoration => [:underline]})
    elsif name == 'a'
      # filter out the index.html and root links
      href = attributes.assoc('href') ? attributes.assoc('href')[1] : ''
      ignore = false
      footnote = false
      if ['index.html','/','http://benyehuda.org','http://www.benyehuda.org','http://benyehuda.org/','http://www.benyehuda.org/'].include? href # TODO: de-uglify
        ignore = true
      else
        # probably a footnote, but could be anything
        # Word-generated footnote references look like this: 
        # <a style='mso-footnote-id:ftn12' href="#_ftn12" name="_ftnref12" title="">
        # (followed by a zillion pointless <span> tags...)
        # Then, the footnote itself looks like this:
        # <a style='mso-footnote-id:ftn12' href="#_ftnref12" name="_ftn12" title="">
        if href.match /_ftn(\d+)/
          footnote_id = $1
          @markdown += "[^ftn#{footnote_id}]" # this is the multimarkdown for a footnote reference
          # nothing useful in the content of the anchor of the footnote 
          # reference -- a hyperlink to and from the footnote will be 
          # auto-generated when rendering HTML, PDF, etc.
          ignore = true
        elsif href.match /_ftnref(\d+)/
          # the beginning of another footnote body (identified through the 
          # hyperlink to the footnote reference) is really our only sign that 
          # the previous footnote body ended...
          end_footnote(@footnote)
          # start a new footnote, remembering this till the next footnote beginning
          @footnote = {:key => $1, :body => '', :markdown => '' } 
          @in_footnote = true
          ignore = true # nothing useful, see in the if block just above
        else
          # TODO: handle (preserve) non-footnote links
          ignore = true # TODO: set this to false and actually handle this...
        end
      end
      @links.push({:href => href, :ignore => ignore})
    end
  end

  def characters s
    if @links.empty? or @links.last['ignore']
      if (s =~ /\S/)
        @spans.last[:anything] = true if @spans.count > 0 
      end
      reformat = s.gsub("\n", ' ')
      if @in_title
        @title += reformat
      elsif @in_footnote # buffer footnote bodies separately
        @footnote[:body] += reformat 
      elsif not @spans.empty?
        @spans.last[:markdown] += reformat
      else
        @markdown += reformat
      end
    end
  end

  def error(e)
    puts "ERROR: #{e}" unless /Tag o:p/.match(e) # ignore useless Office tags
  end

  def end_element(name)
    #puts "end element #{name}"
    if name == 'title' 
      @in_title = false
      puts "title found: #{@title}"
      @markdown += "# #{@title}\n"
    elsif name == 'span' || name == 'b' || name == 'u'
      span = @spans.pop
      new_markdown = ''
      if span[:anything] # don't emit any formatting for the (numerous) useless spans Word generated
        # TODO: determine formatting
        start_formatting = ''
        end_formatting = ''
        if span[:style][:decoration].include? :bold 
          start_formatting += "**" # MultiMarkdown
          end_formatting += "**"
        end
        # poetry, bold, underline, indents, size, footnotes, links
        new_markdown += start_formatting + span[:markdown] + end_formatting # payload
      else
        new_markdown += span[:markdown] # just copy the content, no formatting change
      end
      unless @spans.empty?
        @spans.last[:markdown] += new_markdown
      else
        @markdown += new_markdown
      end
    elsif name == 'br' || name == 'p'
      unless @spans.empty?
        @spans.last[:markdown] += "\n\n"
      else
        @markdown += "\n\n"
      end
    elsif name == 'a'
      link = @links.pop
    end
  end

  def save(fname)
    unless @post_processing_done
      post_process
      @post_processing_done = true
    end
    File.open("/tmp/markdown.txt", 'wb') {|f| f.write(@markdown) } # tmp debug
    File.open("/tmp/markdown.html", 'wb') {|f| f.write(MultiMarkdown.new(@markdown).to_html) }
    File.open(fname, 'wb') {|f| f.write(@markdown) } # works on any modern Ruby
  end

  def end_footnote(f)
    unless f == {}
      # generate MultiMarkDown for the footnote body and stash it for later
      f[:markdown] = "\n[^ftn#{f[:key]}]: " + f[:body] # make sure the footnote body starts on a newline; superfluous newlines will be removed at post-processing 
      @footnotes.push f
    end
  end

  def post_process # handle any wrap up 
    end_footnote(@footnote) # where footnotes exist at all, the last footnote will be pending
    # emit all accumulated footnotes
    markdown = ''
    @footnotes.each { |f|
      markdown += f[:markdown]
    }
    @markdown += markdown.gsub("\n\n[^","\n[^") # append the entire footnotes section, trimming double newlines
    @markdown.gsub!("\r",'') # farewell, DOS! :)
    debugger
    # remove first line's whitespace
    lines = @markdown.split "\n\n" # by newline by default
    z = /\n[\s]*/.match lines[0]
    lines[0] = z.pre_match + "\n" + z.post_match
    @markdown = lines.join "\n\n" 
  end
end

class HtmlFile < ActiveRecord::Base

  def analyze
    # Word footnotes magic word 'mso-footnote-id'
    begin
      html = File.open(self.path, "r:windows-1255:UTF-8").read
      self.footnotes = (html =~ /mso-footnote-id/) ? true : false
      # Word images magic word: '<img'
      self.images = (html =~ /<img/) ? true : false
      # Word tables magic word (beyond the basic BY formatting table for prose!):
      buf = html
      html.match /<body[^>]*>(.*)<\/body>/m
      nikkud_info = count_nikkud($1)
      case
        when nikkud_info[:nikkud] == 0
          self.nikkud = "none"
        when (nikkud_info[:total] > 1000 and nikkud_info[:ratio] < 0.6)
          self.nikkud = "some"
        when (nikkud_info[:total] <= 1000 and nikkud_info[:ratio] < 0.3)
          self.nikkud = "some"
        else
          self.nikkud = "full"
      end
      self.tables = false # unless proven otherwise below
      while buf =~ /<table[^>]*>/ do
        # ignore the Ben-Yehuda standard prose 70% table
        thematch = $~.to_s
        if thematch !~ /<table[^>]*width=\"70%\"[^>]*>/
          self.tables = true
        end
        buf = $' # postmatch
      end
      # debugging # print "Analysis results -- footnotes: #{self.footnotes}, images: #{self.images}, tables: #{self.tables}\n"
      self.status = 'Analyzed' if ['Unknown','FileError', 'BadCP1255'].include? self.status
      self.save!
    rescue 
      print "error: #{$!}\n"
      if $!.to_s =~ /conversion/
        print "match!"
        self.status = 'BadCP1255'
      else
        print "no match?! err = #{$!}\n"
        self.status = 'FileError'
      end
      self.save!
    end
  end
  def self.analyze_all # class method
    HtmlFile.find_all_by_status('Unknown').each { |h| h.analyze }
  end

  # this method is, for now, deliberately only callable manually, via the console
  def fix_encoding
    if self.status == 'BadCP1255'
      raw = IO.binread(self.path)
      ENCODING_SUBSTS.each { |s|
        raw.gsub!(s[:from], s[:to])
      }
      #raw.gsub!("\xCA","\xC9") # fix weird invalid chars instead of proper Hebrew xolams
      #raw.gsub!("\xFC","&uuml;") # fix u-umlaut with a character entity
      #raw.gsub!("\xFB","&uuml;") # fix u-umlaut with a character entity
      newfile = self.path + '.fixed_encoding'
      # IO.binwrite(newfile, raw) # this works only on Ruby 1.9.3+
      File.open(newfile, 'wb') {|f| f.write(raw) } # works on any modern Ruby
      begin
        html = File.open(newfile, "r:windows-1255:UTF-8").read
        # yay! The file is now valid and converts fine to UTF-8! :)
        print "Success! #{newfile} is valid!  Please replace the live file #{self.path} with #{newfile} manually, for safety.\nI'll wait for you to verify: type 'y' if you want to do this switcheroo NOW: " 
        yes = gets.chomp
        if yes == "y"
          File.rename(self.path, "#{self.path}.bad_encoding")
          File.rename(newfile, self.path)
        end 
        self.status = 'Unknown' # so that this file gets re-analyzed after the manual copy
        self.save!
      rescue
        print "fix_encoding replaced 0xCA with 0xC9 but fixed file #{newfile} is still unreadable!  Error: #{$!}\n" # debug
      end
    else
      print 'fix_encoding called but status doesn''t indicate BadCP1255... Ignoring.' # debug
    end
  end
  def parse
    html = File.open(self.path, "r:windows-1255:UTF-8").read
    ndoc = NokoDoc.new
    parser = Nokogiri::HTML::SAX::Parser.new(ndoc)
    parser.parse(html)
    ndoc.save(self.path+'.markdown')
    self.status = 'Parsed' # TODO: error checking?
    self.save!
  end
  def self.new_since(t) # pass a Time
    where("created_at > ?", t.to_s(:db))
  end
  protected

  # return a hash like {:total => total_number_of_non_tags_characters, :nikkud => total_number_of_nikkud_characters, :ratio => :nikkud/:total }
  def count_nikkud(text)
    info = { :total => 0, :nikkud => 0, :ratio => nil }
    ignore = false
    text.each_char {|c|
      if c == '<'
        ignore = true
      elsif c == '>' 
        ignore = false
        next
      end
      unless ignore or c.match /\s/ # ignore tags and whitespace
        info[:nikkud] += 1 if ["\u05B0","\u05B1","\u05B2","\u05B3","\u05B4","\u05B5","\u05B6","\u05B7","\u05B8","\u05B9","\u05BB","\u05BC","\u05C1","\u05C2"].include? c
        info[:total] += 1
      end
    }
    info[:total] -= 35 # rough compensation for text of index and main page links, to mitigate ratio problem for very short texts
    info[:ratio] = info[:nikkud].to_f / info[:total] 
    puts "DBG: total #{info[:total]} - nikkud #{info[:nikkud]} - ratio #{info[:ratio]}"
    return info
  end
end

