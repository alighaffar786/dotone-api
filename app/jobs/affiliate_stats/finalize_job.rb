# frozen_string_literal: true

class AffiliateStats::FinalizeJob < MaintenanceJob
  def perform(affiliate_stat_ids, step_id)
    step = ConversionStep.cached_find(step_id)

    status = if step.auto_approve?
      Order.status_approved
    else
      Order.status_rejected
    end

    affiliate_stats = AffiliateStat
      .conversions
      .preload(:copy_order)
      .where(id: affiliate_stat_ids, approval: AffiliateStat.approvals_considered_pending(:network))

    affiliate_stats.each do |affiliate_stat|
      updates = {
        trace_custom_agent: "System - PAST DUE [#{step.id} - #{step.on_past_due}]",
        status: status,
      }

      begin
        if step.name != affiliate_stat.step_name && step.cached_offer.multi_conversion_point?
          Sentry.capture_exception("Step name did not match #{affiliate_stat.id} #{step.id}")
          next
        end

        if step.offer_id != affiliate_stat.offer_id
          Sentry.capture_exception("Offer ID did not match #{affiliate_stat.id} #{step.id}")
          next
        end

        # Make sure to check for Pending approval in case
        # of discrepancies
        if affiliate_stat.considered_pending?(:network)
          if status == Order.status_approved && affiliate_stat.inconclusive?
            updates.merge!(status: Order.status_rejected)
          end

          (affiliate_stat.copy_order || affiliate_stat).update!(updates)
          PAST_DUE_LOGGER.warn "    #{status} #{affiliate_stat.id}"
        else
          PAST_DUE_LOGGER.warn "    SKIPPED #{affiliate_stat.id}"
        end
      rescue Exception => e
        Sentry.capture_exception(e)
        PAST_DUE_LOGGER.error "ERROR: #{affiliate_stat.id} #{e.message}"
      end
    end
  end
end
