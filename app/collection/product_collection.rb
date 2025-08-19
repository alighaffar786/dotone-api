class ProductCollection < BaseCollection
  attr_reader :offers_map

  def initialize(relation, params = {}, offers_map: {}, **options)
    @offers_map = offers_map
    params[:offer_ids] ||= params[:offer_id]
    super(relation, params, **options)
  end

  private

  def ensure_filters
    filter_by_available_offers if @relation.is_a?(Array)
    filter_by_min if params[:min].present?
    filter_by_max if params[:max].present?
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_updated_at if params[:updated_since].present?
    filter_by_promotion if params[:is_promotion]
    filter_by_locale if params[:product_locale].present?
    filter_by_category_1 if params[:category_1].present?
  end

  def filter_by_available_offers
    filter do
      offer_ids = @offers_map.keys
      @relation.select { |product| offer_ids.include?(product.offer_id) }
    end
  end

  def assign_max_commission
    filter do
      @relation.map do |product|
        product.max_commission = calc_max_commission(product)
        product
      end
    end
  end

  def filter_by_offer_ids
    filter do
      if @relation.is_a?(Array)
        @relation.select do |product|
          params[:offer_ids].include?(product.offer_id.to_s)
        end
      else
        @relation.where(offer_id: params[:offer_ids])
      end
    end
  end

  def filter_by_min
    filter do
      @relation.select! do |product|
        product.forex_price(currency_code) >= params[:min].to_f
      end

      filter_offers!(@relation)
      @relation
    end
  end

  def filter_by_max
    filter do
      @relation.select! do |product|
        product.forex_price(currency_code) < params[:max].to_f
      end

      filter_offers!(@relation)
      @relation
    end
  end

  def filter_by_updated_at
    filter do
      @relation.between(params[:updated_since], nil, :updated_at, any: true)
    end
  end

  def filter_by_promotion
    filter { @relation.with_promotion(params[:is_promotion]) }
  end

  def filter_by_locale
    filter { @relation.with_locales(params[:product_locale]) }
  end

  def filter_by_category_1
    filter do
      @relation.where(category_1: params[:category_1].split(','))
    end
  end

  def ensure_sort
    return @relation if params[:sort_by].blank?

    sort do
      case params[:sort_by]
      when 'price_asc'
        @relation.sort_by { |product| product.price.to_f }
      when 'price_desc'
        @relation.sort_by { |product| -product.price.to_f }
      when 'comm_asc'
        assign_max_commission.sort_by { |product| product.max_commission.to_f }
      when 'comm_desc'
        assign_max_commission.sort_by { |product| -product.max_commission.to_f }
      else
        if @relation.is_a?(Array)
          @relation
        else
          @relation.order(updated_at: :desc)
        end
      end
    end
  end

  def calc_max_commission(product)
    offer = offers_map[product.offer_id]
    max_affiliate_pay = offer.max_affiliate_pay.to_f
    max_affiliate_share = offer.max_affiliate_share.to_f

    [
      max_affiliate_pay,
      max_affiliate_share * product.forex_price(currency_code) / 100,
    ].max
  end

  def filter_offers!(products)
    offer_ids = products.map(&:offer_id)
    @offers_map.select! { |id| offer_ids.include?(id) }
  end
end
