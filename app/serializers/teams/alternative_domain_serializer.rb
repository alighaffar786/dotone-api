class Teams::AlternativeDomainSerializer < ApplicationSerializer
  attributes :id, :host, :host_type, :visible, :adult_only?, :temporary?, :permanent?, :usage_count,
    :click_count, :status, :expired_at, :name_servers, :load_balancer_dns_name

  def stats
    instance_options.dig(:stats, object.id) || []
  end

  def usage_count
    map_values(stats.group_by(&:date), :tracking_usage_count)
  end

  def click_count
    map_values(stats.group_by(&:date), :tracking_click_count)
  end

  def map_values(values, key)
    start_at, end_at = time_zone.local_range(:last_60_days)
    (start_at.to_date..end_at.to_date).map do |date|
      values[date]&.sum { |val| val.send(key) } || 0
    end
  end
end
