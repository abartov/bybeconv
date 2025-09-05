require 'omnidocx'
require 'csv'
require 'debug'

JUDGES = 5
INPUT_CSV = ARGV[1] || 'input.csv'

def remaining_judges(judge_index)
  [*(0..JUDGES - 1)].reject { |i| i == judge_index || @judge_portions[i].size >= 100 }
end

def next_judge(judge_index)
  i = judge_index == JUDGES - 1 ? 0 : judge_index + 1
  while i != judge_index
    return i if @judge_portions[i].size < 100

    i = i == JUDGES - 1 ? 0 : i + 1
  end
  @judge_portions[i].size < 100 ? judge_index : nil
end

## generate per-judge DOCXs (two DOCX files with 50 works each for each judge)
def make_docxes
  puts 'Making DOCX files for judges'
  JUDGES.times do |i|
    print "Making DOCX files for judge #{i + 1}... "
    filenames = @judge_portions[i].map { |id| "output/#{id}.docx" }
    Omnidocx::Docx.merge_documents(filenames.take(filenames.size / 2), "output/judge_#{i + 1}_part1.docx", true)
    print 'verifying part 1... '
    File.open('ids_to_verify.txt', 'w') { |f| f.puts @judge_portions[i].take(filenames.size / 2).join(' ') }
    verification = `ruby contest_2024_verify.rb output/judge_#{i + 1}_part1.docx`
    print verification
    print 'now part 2... '
    Omnidocx::Docx.merge_documents(filenames.drop(filenames.size / 2), "output/judge_#{i + 1}_part2.docx", true)
    print 'verifying part 2... '
    File.open('ids_to_verify.txt', 'w') { |f| f.puts @judge_portions[i].drop(filenames.size / 2).join(' ') }
    verification = `ruby contest_2024_verify.rb output/judge_#{i + 1}_part2.docx`
    print verification
    puts 'done'
  end
end

# main
puts "assigning works to #{JUDGES} judges"
## assign works to judges
@raw_csv = CSV.read(INPUT_CSV)

@judge_portions = []
@assignments = {}
JUDGES.times { @judge_portions << [] }
judge = 0
# CSV columns: 0: id, 1:rank, 2:gdoc link, 3:pby title, 4:pby link, 5:part, 6:genre, 7:commentary
processed = 0
csv = @raw_csv[1..-1].select { |row| row[1].to_i < 4 }.shuffle # pick only rows with rank < 4, and randomize
csv.each do |row|
  id = row[0]
  next if id.nil?

  @judge_portions[judge] << id
  second_judge = remaining_judges(judge).sample
  if second_judge.nil?
    puts "ERROR: no remaining second judges for #{id} after processing #{processed} works"
  else
    @judge_portions[second_judge] << id
  end
  judge = next_judge(judge)
  if judge.nil?
    puts "ERROR: no remaining first judges for #{id} after processing #{processed} works"
    break
  end
  @assignments[id] = [judge, second_judge]
  processed += 1
  puts "processed #{processed} works" if processed % 25 == 0
end

## generate per-judge CSVs
puts 'generating per-judge CSVs'
JUDGES.times do |i|
  fname = "output/judge_#{i + 1}.csv"
  File.open(fname, 'w') do |f|
    f.puts CSV.generate_line([@raw_csv[0][0], *@raw_csv[0][2..7]])
    @judge_portions[i].each do |id|
      row = csv.find { |r| r[0] == id }
      f.puts CSV.generate_line([row[0], *row[2..7]])
    end
  end
  puts "wrote #{fname}"
end

puts 'Ready for DOCX generation? (y/n)'
exit unless gets.chomp == 'y'

make_docxes

puts 'Bye!'
