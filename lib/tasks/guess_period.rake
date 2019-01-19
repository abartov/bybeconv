desc "Guess the period for authors without a period (hardcoded)"
task :guess_period => :environment do
  guessed = 0
  processed = 0
  total = Person.has_toc.count
  Person.has_toc.each do |p|
    processed += 1
    puts "processed #{processed}/#{total}, guessed #{guessed} periods" if processed % 10 == 0
    if p.period.nil? || p.period.empty?
      guess = guess_the_period(p)
      unless guess.nil?
        p.period = guess
        p.save!
        guessed += 1
      end
    end
  end

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
  return nil # deliberate let some range around englightenment and modern period slip through, for manual decisions
end

