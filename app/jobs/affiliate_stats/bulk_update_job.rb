# frozen_string_literal: true

class AffiliateStats::BulkUpdateJob < EntityManagementJob
  def perform(user:, ids:, params:)
    ability = Ability.new(user)
    affiliate_stats = AffiliateStat.conversions.accessible_by(ability, :update).where(id: ids).preload(:offer, :copy_order)
    user_role = ability.user_role

    return unless [:network, :owner].include?(user_role)

    params = params.with_indifferent_access
    params = params.select { |_, v| v.is_a?(Array) ? v[0].present? : v.present? }

    update_params = { status: params[:status] || AffiliateStat.decide_status(params[:approval]) }.compact
    update_params.merge!(params.slice(:captured_at_local, :published_at_local, :converted_at_local)) if user_role == :owner
    update_params.symbolize_keys!

    true_pay, currency_code = params[:forex_true_pay]
    affiliate_pay, currency_code = params[:forex_affiliate_pay]

    true_pay_given = true_pay.present?
    true_share_given = params[:true_share].present? && params[:true_share].to_f > 0
    affiliate_pay_given = affiliate_pay.present?
    affiliate_share_given = params[:affiliate_share].present? && params[:affiliate_share].to_f > 0

    true_pay = true_pay_given ? true_pay.to_f : nil
    affiliate_pay = affiliate_pay_given ? affiliate_pay.to_f : nil

    true_share = params[:true_share].to_f if true_share_given
    affiliate_share = params[:affiliate_share].to_f if affiliate_share_given

    skip_existing_payout = true_pay_given || true_share_given
    skip_existing_commission = affiliate_pay_given || affiliate_share_given || skip_existing_payout

    affiliate_stats.find_each do |stat|
      next unless stat.conversions?
      next if user_role == :network && stat.considered_approved?

      if order = stat.copy_order
        if recorded_at_local = update_params.delete(:captured_at_local)
          update_params.merge!(recorded_at_local: recorded_at_local)
        end
      end

      if user_role == :owner
        if true_share_given || affiliate_share_given || (true_pay_given && true_pay > 0) || (affiliate_pay_given && affiliate_pay > 0)
          options = {
            currency_code: currency_code,
            skip_existing_commission: skip_existing_commission,
            skip_existing_payout: skip_existing_payout,
          }

          options[:true_share] = true_share if true_share_given
          options[:affiliate_share] = affiliate_share if affiliate_share_given
          options[:true_pay] = true_pay if true_pay_given && !true_share_given
          options[:affiliate_pay] = affiliate_pay if affiliate_pay_given && !affiliate_share_given

          _, _, order_total_to_record, payout, commission, payout_share, commission_share = stat.calculate_payout_and_commission(stat.order_total, nil, stat.step_name, options)

          if order.present?
            update_params.merge!(
              total: order_total_to_record,
              true_pay: payout,
              true_share: payout_share,
              affiliate_pay: commission,
              affiliate_share: commission_share,
            )
          else
            update_params.merge!(
              order_total: order_total_to_record,
              true_pay: payout,
              affiliate_pay: commission,
            )
          end
        elsif (true_pay_given && true_pay == 0) || (affiliate_pay_given && affiliate_pay == 0)
          update_params[:true_pay] = true_pay if true_pay_given
          update_params[:affiliate_pay] = affiliate_pay if affiliate_pay_given
        end
      end

      next if update_params.blank?

      update_params.merge!(trace_agent_via: 'Bulk Update')

      DotOne::Utils::Rescuer.no_deadlock do
        if order.present?
          order.update!(update_params)
          stat.reload
        else
          stat.update!(update_params)
        end
      end
    end
  end
end
