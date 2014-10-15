require 'tempfile' 

desc "Figure out the character position with bad Windows-1255 encoding of given file"
task :badchar, :filename do |t, args|
  filename = args[:filename]
  print "reading #{filename}...\n"
  begin
    all = File.open(filename, 'r:windows-1255:UTF-8').read
  rescue
    debugger
    print "file has bad encoding.  Investigating...\n"
    File.open(filename, 'r:windows-1255:UTF-8') {|f|
      while not f.eof?
        begin
          c = f.readchar
        rescue
          print "problem is at #{f.tell} bytes\n"
          exit
        end
      end
    }
  end
  print "all good!\n"
end

