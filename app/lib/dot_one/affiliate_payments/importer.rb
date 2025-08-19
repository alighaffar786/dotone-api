# frozen_string_literal: true

class DotOne::AffiliatePayments::Importer
  attr_accessor :upload, :errors

  WHITE_LISTED = [
    :previous_amount,
    :referral_amount,
    :affiliate_amount,
    :status,
    :paid_date,
    :start_date,
    :end_date,
    # :billing_region,
  ].freeze

  def initialize(upload_id)
    @upload = Upload.find(upload_id)
    @errors = []
  end

  def import
    update_upload_status do
      upload.csv_rows.each do |row|
        affiliate = find_affiliate_and_validate(row)
        row = validate_date_fields(affiliate, row)

        affiliate.affiliate_payments.create!(row.slice(*WHITE_LISTED))
      rescue DotOne::Errors::BaseError => e
        errors << e.full_message
        next
      end
    end
  end

  private

  def update_upload_status
    upload.update(status: Upload.status_in_progress)

    yield

    if errors.present?
      @upload.status = Upload.status_error
      @upload.error_details = errors.join("\n")
    else
      @upload.status = Upload.status_ready
      @upload.error_details = nil
    end

    @upload.save
  rescue ActiveRecord::ValueTooLong
    @upload.upload_error_details
    @upload.save
  end

  def find_affiliate_and_validate(row)
    affiliate = Affiliate.cached_find(row[:affiliate_id])
    raise DotOne::Errors::PaymentError::UnknownAffiliateError, row if affiliate.blank?

    affiliate
  end

  def validate_date_fields(affiliate, row)
    [:paid_date, :start_date, :end_date].each do |key|
      row[key] = Date.parse(row[key].to_s)
    rescue Date::Error
      raise DotOne::Errors::InvalidDataError.new(row, 'data.invalid_date_format', key)
    end

    # if AffiliatePayment.overlapped_payments(affiliate, row[:billing_region], row[:start_date], row[:end_date]).empty?
    if AffiliatePayment.overlapped_payments(affiliate, 'all', row[:start_date], row[:end_date]).empty?
      row
    else
      raise DotOne::Errors::PaymentError::OverlappedPaymentError, row
    end
  end
end
