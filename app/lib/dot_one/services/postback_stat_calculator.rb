class DotOne::Services::PostbackStatCalculator
  attr_reader :affiliate_stats, :original_stats

  def initialize(affiliate_stats)
    @affiliate_stats = affiliate_stats.to_a
  end

  def affiliate_stat_ids_map
    @affiliate_stat_ids_map ||= affiliate_stats.each_with_object({}) do |affiliate_stat, result|
      if original_id = affiliate_stat.original_id.presence
        result[original_id] = affiliate_stat.id
      else
        result[affiliate_stat.id] = affiliate_stat.id
      end
    end
  end

  def original_ids
    affiliate_stat_ids_map.keys
  end

  def affiliate_stat_ids
    affiliate_stat_ids_map.values
  end

  def all_affiliate_stat_ids
    original_ids | affiliate_stat_ids
  end

  def calculate
    postback_stats = query_postback_stats

    original_ids.each_with_object({}) do |original_id, result|
      postback_stat = postback_stats[original_id]
      affiliate_stat_id = affiliate_stat_ids_map[original_id]

      unless original_id == affiliate_stat_id
        extra_stat = postback_stats[affiliate_stat_id]
        postback_stat = postback_stat.merge(extra_stat) { |_, old_val, new_val| old_val + new_val }
      end

      result[original_id] = postback_stat
    end
  end

  private

  def query_postback_stats
    return {} if all_affiliate_stat_ids.empty?

    result = {}
    empty_stat = { incoming: 0, outgoing: 0 }

    Postback
      .where(affiliate_stat_id: all_affiliate_stat_ids)
      .group(:affiliate_stat_id, :postback_type)
      .count
      .map do |item, count|
        affiliate_stat_id, postback_type = item
        result[affiliate_stat_id] ||= empty_stat.dup
        result[affiliate_stat_id][ConstantProcessor.to_method_name(postback_type)] = count
      end

    all_affiliate_stat_ids.each do |affiliate_stat_id|
      result[affiliate_stat_id] ||= empty_stat
    end

    result
  end
end
