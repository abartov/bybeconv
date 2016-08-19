require 'tempfile'

desc "Figure out the character position with bad UTF-8 encoding of given file"
task :badutf8, :filename do |t, args|
  filename = args[:filename]
  print "reading #{filename}...\n"
  begin
    all = File.open(filename, 'r:UTF-8').read
  rescue
    #debugger
    print "file has bad encoding.  Investigating...\n"
    File.open(filename, 'r:UTF-8') {|f|
      while not f.eof?
        begin
          c = f.readchar
        rescue
          print "problem is at #{f.tell} bytes\nvim +#{f.tell}go #{filename}\n"
          exit
        end
      end
    }
  end
  print "all good!\n"
end

