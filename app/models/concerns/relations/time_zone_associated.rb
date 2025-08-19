module Relations::TimeZoneAssociated
  extend ActiveSupport::Concern

  included do
    belongs_to :time_zone, inverse_of: self.name.tableize
  end

  def default_time_zone
    @default_time_zone ||= time_zone || TimeZone.platform
  end

  def time_zone_gmt
    default_time_zone.gmt
  end

  def cached_time_zone
    TimeZone.cached_find(time_zone_id)
  end
end
