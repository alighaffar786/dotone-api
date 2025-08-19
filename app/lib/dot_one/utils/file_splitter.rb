##
# Split big CSV file into smaller partitions
# so each upload process will be short and
# takes less memory

class DotOne::Utils::FileSplitter
  attr_accessor :original_file

  def initialize(original_file)
    @original_file = original_file
  end

  def splits(lines_per_file)
    header_lines = 1
    lines = `sed -n '=' '#{@original_file}' | wc -l`.to_i - header_lines
    header = `head -n #{header_lines} '#{original_file}'`
    file_count = (lines / lines_per_file.to_f).ceil

    start = 0

    file_count.times do |i|
      finish = start + lines_per_file
      file = "#{original_file}-#{i}.csv"

      File.write(file, header)
      `tail -n #{lines - start} '#{original_file}' | head -n #{lines_per_file} >> '#{file}'`

      start = finish
      yield(file, i)
    end
  end
end
