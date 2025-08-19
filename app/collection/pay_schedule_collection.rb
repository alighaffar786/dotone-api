class PayScheduleCollection < BaseCollection
  private

  def ensure_filters
    super

    filter_by_affiliate_offer_ids if params[:affiliate_offer_ids].present?
    filter_by_conversion_step_ids if params[:conversion_step_ids].present?
    filter_by_owned_by if params[:owner_type].present?
    filter_by_available if params[:available].present?
  end

  def filter_by_affiliate_offer_ids
    filter do
      @relation
        .where(owner_type: 'StepPrice')
        .where(owner_id: StepPrice.where(affiliate_offer_id: params[:affiliate_offer_ids]))
    end
  end

  def filter_by_conversion_step_ids
    filter { @relation.where(owner_id: StepPrice.where(conversion_step_id: params[:conversion_step_ids])) }
  end

  def filter_by_owned_by
    filter { @relation.owned_by(params[:owner_type], params[:owner_id]) }
  end

  def filter_by_available
    filter { @relation.available }
  end

  def default_sorted
    sort { @relation.order(ends_at: :desc, starts_at: :desc) }
  end
end
