class Teams::AffiliateStat::IndexSerializer < Base::AffiliateStatSerializer
  class OrderSerializer < Base::OrderSerializer
    attributes :id, :order_number, :status, :real_total, :true_currency_code, :days_return,
      :days_since_order, :days_return_past_due?, :affiliate_stat_id
  end

  class EventOfferSerializer < Base::EventOfferSerializer
    attributes :id, :name, :status, :conversion_point
  end

  attributes :id, :transaction_id, :status, :copy_stat_id, :affiliate_id, :offer_id, :browser, :browser_version, :isp,
    :device_brand, :device_model, :device_type, :ip_address, :http_referer, :referer_domain, :http_user_agent,
    :recorded_at, :captured_at, :published_at, :converted_at, :aff_uniq_id, :adv_uniq_id, :is_event_offer,
    :subid_1, :subid_2, :subid_3, :subid_4, :subid_5, :single_point?, :multi_point?, :conversions, :transaction_locked?

  conditional_attributes :network_id, :true_conv_type, :affiliate_conv_type, :order_total, :true_pay, :affiliate_pay,
    :calculated_margin, :approval, :postback_stats, :gaid, :skip_api_refresh, :step_label, :step_name, :order_number,
    :order_real_total, :true_currency_code, if: :not_clicks?

  has_one :country
  has_one :affiliate, serializer: Teams::Affiliate::MiniSerializer, if: :can_read_affiliate?
  has_one :network, serializer: Teams::Network::MiniSerializer, if: :include_network?
  has_one :offer, if: :can_read_network_offer?
  has_one :copy_order, key: :order, serializer: OrderSerializer, if: :not_clicks?

  def self.serializer_for(model, options)
    case model.class.name
    when 'EventOffer'
      EventOfferSerializer
    when 'NetworkOffer'
      Teams::NetworkOffer::MiniSerializer
    else
      super
    end
  end

  def postback_stats
    if (given = instance_options[:postback_stats])
      given[transaction_id]
    else
      object.postback_stats
    end
  end

  def skip_api_refresh
    if (given = instance_options[:skip_api_refresh])
      given[object.id] || false
    else
      object.skip_api_refresh
    end
  end

  def include_network?
    not_clicks? && can_read_network?
  end

  def not_clicks?
    instance_options[:clicks].blank?
  end

  def is_event_offer
    object.offer.instance_of?(EventOffer)
  end
end
