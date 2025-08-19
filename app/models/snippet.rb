class Snippet < DatabaseRecords::PrimaryRecord
  include Owned

  attr_accessor :source_affiliate_id, :source_offer_id, :source_tid, :source_tag

  belongs_to_owner touch: true

  validates :snippet_key, uniqueness: { scope: [:owner_id, :owner_type] }

  after_commit :flush_cache

  serialize :snippet_hash

  scope :like, -> (*args) {
    where('snippet_key LIKE ?', "%#{args[0]}%") if args[0].present?
  }

  def self.cache_key
    DotOne::Utils.to_cache_key(self, 'snippet_hash_keys')
  end

  def self.lookup_hash_keys(query)
    keys = DotOne::Cache.fetch(cache_key, expires_in: 1.year) do
      where.not(snippet_hash: nil).pluck(:snippet_hash).flat_map(&:keys).uniq
    end

    keys.select { |key| key.include?(query.to_s) }
  end

  # format any snippet token on the snippet hash content and replace it with the associated snippet content.
  def formatted_snippet_hash
    return {} if snippet_hash.blank?

    result = {}

    snippet_hash.each_pair do |key, value|
      new_value = value

      # replace snippet tokens
      while new_value.present? && new_value.match(TOKEN_REGEX_SNIPPET)
        # replace with snippet token
        new_value = new_value.gsub(TOKEN_REGEX_SNIPPET) do |_x|
          hash_key = ::Regexp.last_match(1)
          val = snippet_hash[hash_key]
          val
        end
      end

      # replace predefined tokens
      if new_value.present?
        if source_affiliate_id.present?
          new_value = new_value.gsub(TOKEN_SOURCE_AFFILIATE_ID, source_affiliate_id.to_s)
        end

        new_value = new_value.gsub(TOKEN_SOURCE_OFFER_ID, source_offer_id.to_s) if source_offer_id.present?
        new_value = new_value.gsub(TOKEN_SOURCE_TID, source_tid) if source_tid.present?
        new_value = new_value.gsub(TOKEN_SOURCE_TAG, source_tag) if source_tag.present?
      end

      result[key] = new_value
    end

    result
  end

  private

  def flush_cache
    Rails.cache.delete(Snippet.cache_key)
  end
end
