desc "Guess the period for authors without a period (hardcoded)"
task :guess_period => :environment do
  guessed = 0
  processed = 0
  total = Person.has_toc.count
  todo = Person.has_toc.where(period: nil)
  todocount = todo.count
  puts "Out of a total #{total} authors, #{todocount} authors have no period. Trying to guess:"
  todo.each do |p|
    processed += 1
    puts "processed #{processed}/#{todocount}, guessed #{guessed} periods" if processed % 10 == 0
    if p.period.nil? || p.period.empty?
      guess = guess_the_period(p)
      unless guess.nil?
        p.period = guess
        p.save!
        guessed += 1
      end
    end
  end
  puts "finished guessing author periods. Will now proceed to populate expression entities with the period of their translator if translation, or their author if not. To NOT proceed with this, hit CTRL+C."
  proceed = $stdin.gets

  processed = 0
  populated = 0
  total = Expression.count
  todo = Expression.where(period: nil)
  todocount = todo.count
  puts "\nOut of a total of #{total} expressions, #{todocount} have no period set. Trying to assign period by author/translator:"
  todo.each {|e|
    processed += 1
    puts "processed #{processed}/#{todocount}, populated #{populated} periods" if processed % 10 == 0
    relevant_person = e.translation ? e.translators.first : e.works[0].authors.first
    unless relevant_person.nil? || relevant_person.period.nil?
      populated += 1
      e.period = relevant_person.period
      e.save!
    end
  }
  puts "done!"
end

private

# this is a one-time process for existing authors, so this code is hard-coded for the Hebrew literature timeline adopted by Project Ben-Yehuda. Other projects will want their own timeline and would have to rewrite this logic if they want to mass-set periods.

def guess_the_period(p)
  return nil unless p.birthdate
  return nil unless p.birthdate =~ /\d\d\d+/ # assuming no Hebrew authors before 100 AD
  byear = $&
  floruit = byear.to_i + 22 # rough approximation of beginning of literary production
  case floruit
    when -Float::INFINITY...900
      return Person.periods[:ancient]
    when 901..1700
      return Person.periods[:medieval]
    when 1701..1860
      return Person.periods[:enlightenment]
    when 1901..1930
      return Person.periods[:revival]
    when 1948...Float::INFINITY
      return Person.periods[:modern]
  end
  return nil # deliberately let some range around englightenment and modern period slip through, for manual decisions
end

