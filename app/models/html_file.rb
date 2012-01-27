require 'multimarkdown'

class NokoDoc < Nokogiri::XML::SAX::Document
  def initialize
    @markdown = ''
    @in_title = false
    @title = ''
    @anything = false
    @spans = [] # a span/style stack
    @links = [] # a links stack
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
      src = attributes.assoc('src')
      ignore = false
      if ['index.html','/','http://benyehuda.org','http://www.benyehuda.org','http://benyehuda.org/','http://www.benyehuda.org/'].include? src # TODO: de-uglify
        ignore = true
      end
      @links.push({:src => src, :ignore => ignore})
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
    @markdown.gsub!("\r",'') # farewell, DOS! :)
    File.open("/tmp/markdown.txt", 'wb') {|f| f.write(@markdown) } # tmp debug
    File.open("/tmp/markdown.html", 'wb') {|f| f.write(MultiMarkdown.new(@markdown).to_html) }
    File.open(fname, 'wb') {|f| f.write(@markdown) } # works on any modern Ruby
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
      self.status = 'Analyzed' if self.status == 'Unknown' 
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
  def fix_encoding
    if self.status == 'BadCP1255'
      raw = IO.binread(self.path)
      raw.gsub!("\xCA","\xC9") # fix weird invalid chars instead of proper Hebrew xolams
      newfile = self.path + '.fixed_encoding'
      # IO.binwrite(newfile, raw) # this works only on Ruby 1.9.3+
      File.open(newfile, 'wb') {|f| f.write(raw) } # works on any modern Ruby
      begin
        html = File.open(newfile, "r:windows-1255:UTF-8").read
        # yay! The file is now valid and converts fine to UTF-8! :)
        print "Success! #{newfile} is valid!  Please replace the live file #{self.path} with #{newfile} manually, for safety." 
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
end

