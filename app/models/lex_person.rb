class LexPerson < ApplicationRecord
  def parse_books(buf)
    
  end
  def analyze(entry)
    #ret = entry.lex_item.present? ? entry.lex_item : LexPerson.new
    buf = File.open(entry.fname).read
    anchors = buf.scan(/<a name="(.*?)">/)
    ret = ''
    ret += parse_books(buf[/a name="Books".*?<a name/m])
    ret += parse_bib(buf[/a name="Bib.".*?<a name/m])
    ret += parse_links(buf[/a name="links".*?<a name/m])
    return ret
  end

end

# ["Books"]=>4325, ["Bib."]=>3896, ["links"]=>3879, ["top"]=>179, ["no1"]=>67, ["no2"]=>65, ["no3"]=>52, ["no14-15"]=>3, ["no18"]=>8, ["no19"]=>7, ["no20"]=>6, ["Bib.1"]=>3, ["no410"]=>1, ["no411"]=>1, ["no412"]=>1, ["HLN3"]=>3, ["no0101"]=>2, ["no0102"]=>2, ["no010304"]=>2, ["no010506"]=>2, ["no21-22"]=>1, ["no307"]=>2, ["no308"]=>2, ["no309-310"]=>1, ["no311"]=>1, ["no312-313"]=>1, ["no314"]=>2, ["no315"]=>2, ["no316"]=>2, ["no360"]=>4, ["no359"]=>12, ["5552"]=>1, ["5261"]=>3, ["5472"]=>1, ["5502"]=>1, ["5502\" href=\"01227.php"]=>1, ["5433"]=>1, ["5162"]=>3, ["5350"]=>3, ["5350\" href=\"00386.php"]=>1, ["5352"]=>3, ["5352\" href=\"00386.php"]=>1, ["5345"]=>3, ["5
