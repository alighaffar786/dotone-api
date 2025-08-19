# frozen_string_literal: true

class AffiliateStats::FinalizePastDueJob < MaintenanceJob
  def perform(step_ids = nil, n_days = nil, info = nil)
    if ClientApi.order_api.in_progress.exists?
      AffiliateStats::FinalizePastDueJob.set(wait: 1.hour).perform_later(step_ids, n_days, info)
      return
    end

    if step_ids
      steps = ConversionStep.where(id: step_ids).preload(:offer).to_a

      PAST_DUE_LOGGER.warn 'Processing steps for all offers'
      PAST_DUE_LOGGER.warn "Step size: #{steps.size}"

      steps.each do |step|
        PAST_DUE_LOGGER.warn "Processing transactions for Offer #{step.offer_id} - Step (#{step.id}) #{step.name}..."

        if step.do_nothing?
          affiliate_stats = AffiliateStat
            .conversions
            .invalid
            .where(offer_id: step.offer_id)
            .between(1.year.ago, 31.days.ago, :captured_at)
        else
          tz = TimeZone.current
          now = tz.from_utc(Time.now)
          past_due_date_local = (now - (step.days_to_return + 1).days).end_of_day
          past_due_date_utc = tz.to_utc(past_due_date_local)

          # Limit how far back we are looking for pending conversions.
          # Most likely, this routine will execute once a day at the very least.
          # But just in case (very rare) this routine have not run for the past week,
          # we put earliest timestamp to 90 days
          earliest_timestamp_utc = past_due_date_utc - (n_days || 90).days

          # Past due is days to return (conversion period + 1 day)
          affiliate_stats = AffiliateStat
            .conversions
            .where(offer_id: step.offer_id, approval: AffiliateStat.approvals_considered_pending(:network))
            .where('captured_at >= ? AND captured_at <= ?', earliest_timestamp_utc, past_due_date_utc)
        end

        affiliate_stats = affiliate_stats.where(step_name: step.name) if step.cached_offer.multi_conversion_point?
        affiliate_stats_ids = affiliate_stats.pluck(:id)

        next if affiliate_stats_ids.empty?

        wait_time = 0

        until affiliate_stats_ids.empty?
          current_stat_ids = affiliate_stats_ids.shift(1000)
          AffiliateStats::FinalizeJob.set(wait: wait_time.seconds).perform_later(current_stat_ids, step.id)
          wait_time += current_stat_ids.size
        end
      end
    else
      steps = ConversionStep.where(offer: NetworkOffer.all).pluck(:on_past_due, :id)
      approve_step_ids = steps.select { |k, _| k == ConversionStep.on_past_due_auto_approve }.map { |_, v| v }
      reject_step_ids = steps.select { |k, _| k == ConversionStep.on_past_due_auto_reject }.map { |_, v| v }
      nothing_step_ids = steps.reject { |k, _| [ConversionStep.on_past_due_auto_reject, ConversionStep.on_past_due_auto_approve].include?(k) }.map { |_, v| v }
      wait_time = 0

      until approve_step_ids.empty?
        self.class.set(wait: wait_time.minutes).perform_later(approve_step_ids.shift(100), n_days, 'Handle approval')
        wait_time += 5
      end

      until reject_step_ids.empty?
        self.class.set(wait: wait_time.minutes).perform_later(reject_step_ids.shift(100), n_days, 'Handle reject')
        wait_time += 5
      end

      until nothing_step_ids.empty?
        self.class.set(wait: wait_time.minutes).perform_later(nothing_step_ids.shift(100), n_days, 'Handle invalid')
        wait_time += 5
      end
    end
  end
end
