class AlternativeDomainStat < DatabaseRecords::PrimaryRecord
  include DateRangeable

  belongs_to :alternative_domain, inverse_of: :stats, touch: true

  validates :date, presence: true

  def tracking_click_count=(value)
    super(value.to_i)
  end

  def tracking_usage_count=(value)
    super(value.to_i)
  end

  def self.bulk_save_clicks(value_array)
    value_counts = value_array.each_with_object(Hash.new(0)) do |value, counts|
      counts[value] += 1
    end

    new_stats = []

    value_counts.each do |value, counts|
      host = DotOne::Utils::Url.flexible_parse(value['url'].to_s).domain
      next unless domain = AlternativeDomain.find_by_host(host)

      stat = where(alternative_domain_id: domain.id, date: value['date']).first_or_initialize
      stat.tracking_click_count += counts
      if stat.new_record?
        new_stats << stat
      else
        stat.save!
      end
    end

    AlternativeDomain.where(id: new_stats.map(&:alternative_domain_id)).update_all(updated_at: Time.now)
    import(new_stats)
  end
end
