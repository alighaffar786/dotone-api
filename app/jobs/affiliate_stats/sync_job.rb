# frozen_string_literal: true

class AffiliateStats::SyncJob < StatManagementJob
  def perform(ids: nil, start_at: nil, end_at: nil)
    if ClientApi.order_api.in_progress.exists?
      AffiliateStats::SyncJob.set(wait: 1.hour).perform_later(ids: ids, start_at: start_at, end_at: end_at)
      return
    end

    if ids
      stats = Stat.where(id: ids).index_by(&:id)
      captured = AffiliateStatCapturedAt.where(id: ids).index_by(&:id)
      published = AffiliateStatPublishedAt.where(id: ids).index_by(&:id)
      converted = AffiliateStatConvertedAt.where(id: ids).index_by(&:id)

      AffiliateStat.where(id: ids).each do |stat|
        attributes = get_attributes(stat)

        next if mirror_to_redshift(stat, attributes, stats[stat.id])
        next if stat.captured_at? && mirror_to_redshift(stat, attributes, captured[stat.id])
        next if stat.published_at? && mirror_to_redshift(stat, attributes, published[stat.id])
        next if stat.converted_at? && mirror_to_redshift(stat, attributes, converted[stat.id])
      end
    elsif start_at.present? && end_at.present?
      AffiliateStat
        .select(:id)
        .where('recorded_at > ?', Stat.date_limit)
        .where('updated_at BETWEEN ? AND ?', start_at, end_at)
        .find_in_batches(batch_size: 500) do |records|
          self.class.perform_later(ids: records.pluck(:id))
        end
    else
      7.times do |n|
        start_at = (7.days.ago + n.day)
        end_at = start_at + 1.day
        self.class.perform_later(start_at: start_at.to_s(:db), end_at: end_at.to_s(:db))
      end
    end
  end

  def get_attributes(item)
    return {} unless item

    item.attributes
      .except('attribution_level', 'manual_notes', 'approved', 'updated_at', 'forex', 's1', 's2', 's3', 's4')
      .sort
      .to_h
      .transform_values(&:to_s)
  end

  def mirror_to_redshift(affiliate_stat, attributes, copy)
    copy_attributes = get_attributes(copy)

    return if copy_attributes == attributes

    mismatch = attributes
      .keys
      .map { |k| attributes[k] != copy_attributes[k] && [k, attributes[k], copy_attributes[k]] }
      .reject(&:blank?)

    STAT_SYNC_LOGGER.warn "SYNCING #{affiliate_stat.id}:\n\t\t#{copy_attributes.present? ? mismatch : 'ALL'}"

    affiliate_stat.mirror_to_redshift
    true
  end
end
