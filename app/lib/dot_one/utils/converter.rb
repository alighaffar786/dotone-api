class DotOne::Utils::Converter
 # pick entry from bucket hash based on the odd specified as key
  # bucket is a hash something like this:
  # {
  #   75 => "entry 1",
  #   10 => "entry 2",
  #   15 => "entry 3"
  # }
  # That means entry 1, 2 and 3 have odd of 75%, 10%, and 15% respectively.
  def self.hash_splitter_to_value(bucket)
    total = 0
    bucket.keys.each do |k|
      total += k.to_i
    end
    picked_idx = 1 + rand(total)
    picked_key = nil
    current_idx = 0
    bucket.keys.each do |k|
      current_idx += k.to_i
      if picked_idx <= current_idx
        picked_key = k
        break
      end
    end
    bucket[picked_key]
  end

  def self.format_expression(content)
    return if content.blank?
    content = content.gsub(EXPR_REGEX) do |x|
      arg = $1
      # || operator
      if arg.match(/\|\|/)
        chosen = nil
        values = arg.split("||")
        values.each do |value|
          chosen = value.strip rescue nil
          break if chosen.present?
        end
        chosen
      end
    end
    content
  end
end
