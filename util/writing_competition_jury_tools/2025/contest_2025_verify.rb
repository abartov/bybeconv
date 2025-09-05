require 'docx'

def verify(ids, file)
  doc = Docx::Document.open(file)
  to_verify = ids
  doc.paragraphs.each do |p|
    if p.text.include? '&&&'
      id = p.text.split('&&&')[1].strip.match(/\d+/)[0]
      to_verify.delete(id) if id
    end
  end
  if to_verify.empty?
    puts 'looks good!'
  else
    puts "ERROR: missing entries for #{to_verify.join(', ')}!"
  end
end

ids = File.read('ids_to_verify.txt').split
verify(ids, ARGV[0])
