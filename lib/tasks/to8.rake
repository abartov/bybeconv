require 'tempfile'

desc "Convert UTF-16 to UTF-8 of given file"
task :to8, :filename do |t, args|
  filename = args[:filename]
  puts "converting #{filename}...\n"
  `mv #{filename} #{filename}.utf16`
  `iconv -f UTF-16 -t UTF-8 < #{filename}.utf16 > #{filename}`
  puts "CHECK output of file(1) below to ensure it succeeded"
  out = `file #{filename}`
  puts out
  puts "updating charset line"
  buf = File.open(filename, 'r:UTF-8').read
  buf = buf.gsub('charset=unicode','charset=UTF-8').gsub('charset=UNICODE','charset=UTF-8')
  File.truncate(filename, 0)
  File.open(filename, 'w:UTF-8') {|f| f.write(buf) }
  puts "done"
end

