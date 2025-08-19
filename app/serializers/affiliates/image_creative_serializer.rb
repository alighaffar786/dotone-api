class Affiliates::ImageCreativeSerializer < Base::ImageCreativeSerializer
  attributes :id, :cdn_url, :status, :size, :is_infinity_time, :active_date_start, :active_date_end, :locales,
    :ongoing?, :tracking_url, :impression_url
end
