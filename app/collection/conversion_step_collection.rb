class ConversionStepCollection < BaseCollection
  private

  def ensure_filters
    super

    filter_by_offer_type
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_session_option if truthy?(params[:session_option]) || falsy?(params[:session_option])
    filter_by_conversion_modes if params[:conversion_modes].present?
    filter_by_on_past_dues if params[:on_past_dues].present?
    filter_by_true_currency_ids if params[:true_currency_ids].present?
    filter_by_on_conv_types if params[:conv_types].present?
  end

  def filter_by_offer_type
    filter { @relation.joins(:offer).where(offers: { type: params[:offer_type] || 'NetworkOffer' }) }
  end

  def filter_by_offer_ids
    filter { @relation.where(offer_id: params[:offer_ids]) }
  end

  def filter_by_session_option
    if truthy?(params[:session_option])
      filter { @relation.where(session_option: true) }
    else
      filter { @relation.where(session_option: [nil, false]) }
    end
  end

  def filter_by_conversion_modes
    filter { @relation.where(conversion_mode: params[:conversion_modes]) }
  end

  def filter_by_on_past_dues
    filter { @relation.where(on_past_due: params[:on_past_dues]) }
  end

  def filter_by_true_currency_ids
    filter { @relation.where(true_currency_id: params[:true_currency_ids]) }
  end

  def filter_by_on_conv_types
    filter do
      @relation.where(true_conv_type: params[:conv_types]).or(@relation.where(affiliate_conv_type: params[:conv_types]))
    end
  end

  def default_sorted
    sort { @relation.order(offer_id: :desc).ordered }
  end
end
