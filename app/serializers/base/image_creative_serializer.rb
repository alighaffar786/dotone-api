class Base::ImageCreativeSerializer < ApplicationSerializer
  local_time_attributes(*ImageCreative.local_time_attributes)

  def ongoing?
    object.ongoing?(time_zone)
  end

  def tracking_url
    return unless affiliate?

    object.to_tracking_url(current_user)
  end

  def impression_url
    return unless affiliate?

    object.to_impression_url(current_user)
  end

  def download_counts
    instance_options.dig(:download_counts, object.id) || ([0] * 30)
  end
end
