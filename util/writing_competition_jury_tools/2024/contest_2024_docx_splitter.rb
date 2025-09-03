require 'docx'
require 'debug'

INPUT_DOCX = ARGV[0] || 'input.docx'

def process_entry(entry)
  return if entry[:id].nil?

  File.open(fname, 'w') do |f|
    f.puts 'TEXT:'
    f.puts entry[:text].join("\n")
    f.puts
    f.puts 'COMMENTARY:'
    f.puts entry[:commentary].join("\n")
  end
  puts "wrote #{fname}"
end

# main
puts 'splitting DOCX into one DOCX per submission'
@entries = []
doc = Docx::Document.open(INPUT_DOCX) # TODO: support multiple DOCX files
@entry = { from_p: 0, to_p: nil }
in_commentary = false
@pcount = 0
doc.each_paragraph do |p|
  if p.text.include? '&&&'
    @entry[:to_p] = @pcount - 1
    # process_entry(@entry)
    @entries << @entry if @entry[:id]
    @entry = { from_p: @pcount, to_p: nil }
    in_commentary = false
    @entry[:id] = p.text.split('&&&')[1].strip
  end
  @pcount += 1
end
@entry[:to_p] = @pcount - 1
@entries << @entry if @entry[:id] # process last entry

@entries.each do |entry|
  outname = "output/#{entry[:id]}.docx"
  puts "Writing #{outname}"
  `cp #{INPUT_DOCX} output/tmp.docx`
  doc = Docx::Document.open('output/tmp.docx')
  i = 0
  doc.paragraphs.each do |p|
    if i < entry[:from_p] || i > entry[:to_p]
      p.remove!
    elsif p.text.include? '@@@'
      p.each_text_run do |r|
        r.substitute('@@@', '==> דברי הסבר מטעם היוצר/ת על הקשר ליצירה הקיימת בפב"י:')
      end
    end
    i += 1
  end
  doc.save(outname)
end
puts 'Bye!'
