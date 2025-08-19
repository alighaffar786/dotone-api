class AffiliateOfferCollection < BaseCollection
  protected

  def ensure_filters
    super
    filter_by_type
    filter_by_date if params[:start_date].present? || params[:end_date].present?
    filter_by_approval_statuses if params[:approval_statuses].present?
    filter_by_variant_statuses if params[:offer_variant_statuses].present?
    filter_by_network_ids if params[:network_ids].present?
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_affiliate_ids if params[:affiliate_ids].present?
    filter_by_is_custom_commission if truthy?(params[:is_custom_commission]) || falsy?(params[:is_custom_commission])
    filter_by_is_custom_payout if truthy?(params[:is_custom_payout]) || falsy?(params[:is_custom_payout])
    filter_by_affiliate_user_ids if params[:affiliate_user_ids].present?
    filter_by_recruiter_ids if params[:recruiter_ids].present?
    filter_by_pay_schedule_dates if params[:pay_schedule_from].present? || params[:pay_schedule_to].present?
  end

  def filter_by_date
    filter do
      @relation.between(params[:start_date], params[:end_date], :created_at, time_zone, any: true)
    end
  end

  def filter_by_type
    filter { @relation.joins(:offer).where(offers: { type: 'NetworkOffer' }) }
  end

  def filter_by_approval_statuses
    filter { @relation.where(approval_status: params[:approval_statuses]) }
  end

  def filter_by_variant_statuses
    filter do
      @relation
        .joins(:default_offer_variant)
        .where(offer_variants: { status: params[:offer_variant_statuses] })
    end
  end

  def filter_by_network_ids
    filter { @relation.where(offers: { network_id: params[:network_ids] }) }
  end

  def filter_by_offer_ids
    filter { @relation.where(offer_id: params[:offer_ids]) }
  end

  def filter_by_affiliate_ids
    filter { @relation.where(affiliate_id: params[:affiliate_ids]) }
  end

  # For admin only
  # When any step_price is available
  def filter_by_is_custom_commission
    filter { @relation.where(is_custom_commission: params[:is_custom_commission]) }
  end

  def filter_by_is_custom_payout
    filter do
      with_true_pay = @relation.left_outer_joins(step_prices: :pay_schedules)

      with_true_pay = with_true_pay
        .where(step_prices: StepPrice.with_true_pay)
        .or(with_true_pay.where(pay_schedules: PaySchedule.active.with_true_pay))
        .distinct

      if truthy?(params[:is_custom_payout])
        with_true_pay
      else
        @relation.where.not(id: with_true_pay.select(:id))
      end
    end
  end

  def filter_by_affiliate_user_ids
    filter do
      @relation
        .joins(affiliate: :affiliate_assignments)
        .where(affiliate_assignments: { affiliate_user_id: params[:affiliate_user_ids] })
    end
  end

  def filter_by_recruiter_ids
    filter do
      @relation.where(affiliate_id: Affiliate.with_recruiters(params[:recruiter_ids]))
    end
  end

  def filter_by_pay_schedule_dates
    filter do
      @relation = @relation.left_outer_joins(step_prices: :pay_schedules)
      pay_schedules = PaySchedule.active.with_true_pay

      if starts_at = params[:pay_schedule_from].presence
        @relation = @relation.where(pay_schedules: pay_schedules.between(starts_at, nil, :starts_at, any: true))
      end

      if ends_at = params[:pay_schedule_to].presence
        @relation = @relation.where(pay_schedules: pay_schedules.between(nil, ends_at, :ends_at, any: true))
      end

      @relation.distinct
    end
  end

  def default_sorted
    sort do
      if network?
        @relation.order_by_approval_status.order(created_at: :desc)
      else
        @relation.order(created_at: :desc)
      end
    end
  end
end
