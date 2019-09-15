require 'csv'
require 'bybe_utils'
desc "Dump a CSV with works, edition details, ..."
task :dump_works => :environment do
  row = ['benyehuda.org ID','Title','Authors','Translators','Source language','Genre','Word count', 'Source edition details','Source edition year']
  i = 0
  total = Manifestation.count
  CSV.open('benyehuda_works.csv', 'w') do |c|
    c << row
    Manifestation.all.each{ |m|
      i += 1
      puts "Dumping #{i}/#{total}" if i % 50 == 0
      e = m.expressions[0]
      w = e.works[0]
      trstr = ''
      sl = ''
      if e.translation?
        w = e.works[0]
        trstr = m.translators_string
        sl = textify_lang(w.orig_lang)
      end
      c << [m.id, m.title, m.authors_string, trstr, sl, I18n.t(e.genre), m.word_count, e.source_edition, e.date]
    }
  end
end