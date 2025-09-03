require 'omnidocx'
require 'csv'
require 'debug'

MAX_TEXTS = 100 # maximum number of texts per judge
TEXTS_FOR_EVERYONE = [17, 43, 47, 77, 96, 111, 121, 146, 150, 153].freeze
JUDGES = 4
JUDGES_PER_TEXT = 3

INPUT_CSV = ARGV[1] || 'input.csv'
EVERYONE_CSV = 'everyone.csv'.freeze

def remaining_judges(judge_index)
  [*(0..JUDGES - 1)].reject { |i| i == judge_index || @judge_portions[i].size >= MAX_TEXTS }
end

def next_judge(judge_index)
  i = judge_index == JUDGES - 1 ? 0 : judge_index + 1
  while i != judge_index
    return i if @judge_portions[i].size < MAX_TEXTS

    i = i == JUDGES - 1 ? 0 : i + 1
  end
  @judge_portions[i].size < MAX_TEXTS ? judge_index : nil
end

## generate per-judge DOCXs (two DOCX files with 50 works each for each judge)
def make_docxes
  puts 'Making DOCX files for judges'
  JUDGES.times do |i|
    print "Making DOCX files for judge #{i + 1}... "
    # read filenames from each judge's CSV
    ids = File.open("output/judge_#{i + 1}.csv").readlines.map(&:chomp).map { |line| line.split(',')[0] }
    filenames = ids.map { |id| "output/#{id}.docx" }
    Omnidocx::Docx.merge_documents(filenames, "output/judge_#{i + 1}.docx", true)

    print 'verifying... '
    File.open('ids_to_verify.txt', 'w') { |f| f.puts ids.join(' ') }
    verification = `ruby contest_2025_verify.rb output/judge_#{i + 1}.docx`
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
# CSV columns: 0: id, 1:gdoc link, 2:pby title, 3:pby link, 4:part, 5:explanation, 6:commentary

processed = 0
csv = @raw_csv.shuffle # randomize

# Calculate balanced assignment target
num_rows = csv.size
total_assignments = num_rows * JUDGES_PER_TEXT
min_per_judge = total_assignments / JUDGES
extra = total_assignments % JUDGES
judge_targets = Array.new(JUDGES, min_per_judge)
extra.times { |i| judge_targets[i] += 1 }

# Track how many assignments each judge has
judge_counts = Array.new(JUDGES, 0)
csv.each do |row|
  id = row[0]
  next if id.nil?

  # Find judges with the least assignments and still under their target
  available = (0...JUDGES).select { |j| judge_counts[j] < judge_targets[j] }
  # Sort by current count, then shuffle to break ties randomly
  sorted = available.sort_by { |j| [judge_counts[j], rand] }
  assigned_judges = sorted.take(JUDGES_PER_TEXT)
  assigned_judges.each do |judge_idx|
    @judge_portions[judge_idx] << id
    judge_counts[judge_idx] += 1
  end

  processed += 1
  puts "processed #{processed} works" if processed % 25 == 0
end

## generate per-judge CSVs
puts 'generating per-judge CSVs'
JUDGES.times do |i|
  fname = "output/judge_#{i + 1}.csv"
  File.open(fname, 'w') do |f|
    @judge_portions[i].each do |id|
      row = csv.find { |r| r[0] == id }
      f.puts CSV.generate_line(row[0..-2])
    end
  end
  puts "wrote #{fname}"
end

## add everyone.csv to each judge's CSV
JUDGES.times do |i|
  fname = "output/judge_#{i + 1}.csv"
  File.open(fname, 'a') do |f|
    CSV.foreach(EVERYONE_CSV) do |row|
      f.puts CSV.generate_line(row)
    end
  end
  puts "wrote #{fname}"
end

## rewrite each judge's CSV file randomizing the row order
JUDGES.times do |i|
  fname = "output/judge_#{i + 1}.csv"
  rows = CSV.read(fname)
  rows.shuffle!
  File.open(fname, 'w') do |f|
    rows.each do |row|
      f.puts CSV.generate_line(row)
    end
  end
  puts "wrote #{fname}"
end

puts 'Ready for DOCX generation? (y/n)'
exit unless gets.chomp == 'y'

make_docxes

puts 'Bye!'
