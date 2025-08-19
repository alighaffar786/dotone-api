class DotOne::Utils::SemanticVersion
  include Comparable

  attr_reader :major, :minor, :patch

  def initialize(version)
    one, two, three = version.split('.').map(&:to_i)
    @major = one || 0
    @minor = two || 0
    @patch = three || 0
  end

  def <=>(other)
    return unless other.is_a?(SemanticVersion)

    [major, minor, patch] <=> [other.major, other.minor, other.patch]
  end

  ## This method take an array of version in string format
  ## and convert it to array of semantic version
  ## Ex: ["4.0 and newer"] #=> [Semantic(4.0.0) , Semantic(Infinity)]
  def self.string_ver_to_semantic_ver(array)
    negative_infinitive = new(-999_999_999.to_s)
    positive_infinitive = new(999_999_999.to_s)

    array.map do |f|
      if f.end_with?('and newer')
        lower_num = f.gsub(' and newer', '')
        lower_num = new(lower_num)
        [lower_num, positive_infinitive]

      elsif f.end_with?('and older')
        higher_num = f.gsub(' and older', '')
        higher_num = new(higher_num.to_s)

        [negative_infinitive, higher_num]
      elsif f.start_with?('between')
        match = f.match(/\A(?:between\s)(.+)(?:\sand\s)(.+)\z/)
        lower_num = new(match[1])
        higher_num = new(match[2])

        [lower_num, higher_num]
      else
        next # skip if not os version filter
      end
    end
  end
end
