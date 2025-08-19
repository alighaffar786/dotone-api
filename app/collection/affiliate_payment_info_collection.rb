class AffiliatePaymentInfoCollection < BaseCollection
  def ensure_filters
    super
    filter_with_affiliates
    filter_by_statuses
    filter_by_date if params[:start_date].present? || params[:end_date].present?
    filter_by_confirmed_at if params[:confirmed_start_date].present? || params[:confirmed_end_date].present?
    filter_by_affiliates if params[:affiliate_ids].present?
    filter_by_affiliate_users if params[:affiliate_user_ids].present?
    filter_by_payment_types if params[:payment_types].present?
    filter_by_name if params[:name].present?
    filter_by_company_name if params[:company_name].present?
    filter_by_email if params[:email].present?
    filter_by_phone_number if params[:phone_number].present?
  end

  def filter_with_affiliates
    filter { @relation.joins(:affiliate) }
  end

  def filter_by_date
    filter do
      @relation.between(params[:start_date], params[:end_date], :updated_at, time_zone, any: true)
    end
  end

  def filter_by_confirmed_at
    filter do
      @relation.between(params[:confirmed_start_date], params[:confirmed_end_date], :confirmed_at, time_zone, any: true)
    end
  end

  def filter_by_affiliates
    filter do
      @relation.with_affiliates(params[:affiliate_ids])
    end
  end

  def filter_by_affiliate_users
    filter do
      @relation.joins(:affiliate_users).where(affiliate_users: { id: params[:affiliate_user_ids] })
    end
  end

  def filter_by_payment_types
    filter do
      @relation.where(payment_type: params[:payment_types])
    end
  end

  def filter_by_statuses
    filter do
      if params[:statuses].present?
        @relation.with_statuses(params[:statuses])
      else
        @relation.where.not(status: AffiliatePaymentInfo.status_considered_pending)
      end
    end
  end

  def filter_by_name
    filter do
      @relation.with_affiliate_name(params[:name])
    end
  end

  def filter_by_company_name
    filter do
      @relation.with_company_name(params[:company_name])
    end
  end

  def filter_by_email
    filter do
      @relation.with_affiliate_email(params[:email])
    end
  end

  def filter_by_phone_number
    filter do
      @relation.with_affiliate_phone(params[:phone_number])
    end
  end

  def sort_by_bank
    sort do
      @relation.order(
        bank_identification: sort_order,
        bank_name: sort_order,
        branch_identification: sort_order,
        branch_name: sort_order,
      )
    end
  end

  def sort_by_tax_filing_country
    sort do
      @relation.joins(:affiliate).order('affiliates.tax_filing_country' => sort_order)
    end
  end

  def default_sorted
    @relation.order(updated_at: :desc)
  end

  def sort_by_date
    sort { @relation.order(updated_at: sort_order) }
  end
end
