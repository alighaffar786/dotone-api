class AffiliatePaymentCollection < BaseCollection
  def ensure_filters
    super
    filter_by_date if params[:start_date].present? || params[:end_date].present?
    filter_by_affiliate_ids if params[:affiliate_ids].present?
    filter_by_business_entities if params[:business_entities].present?
    filter_by_tax_filing_countries if params[:tax_filing_country_ids].present?
    filter_by_statuses if params[:statuses].present?
    filter_by_billing_region if params[:billing_region].present?
  end

  def filter_by_date
    filter do
      @relation.between(params[:start_date], params[:end_date], :paid_date, time_zone, any: true)
    end
  end

  def filter_by_affiliate_ids
    filter do
      @relation.with_affiliates(params[:affiliate_ids])
    end
  end

  def filter_by_business_entities
    filter do
      @relation.where(business_entity: params[:business_entities])
    end
  end

  def filter_by_tax_filing_countries
    filter do
      countries = Country.where(id: params[:tax_filing_country_ids]).pluck(:name)
      @relation.where(tax_filing_country: countries)
    end
  end

  def filter_by_statuses
    filter do
      @relation.with_statuses(params[:statuses])
    end
  end

  def filter_by_billing_region
    filter do
      @relation.with_billing_regions(params[:billing_region])
    end
  end

  def default_sorted
    @relation.order(paid_date: :desc, id: :desc)
  end

  def sort_by_start_date
    @relation.order(start_date: sort_order, id: sort_order)
  end
end
