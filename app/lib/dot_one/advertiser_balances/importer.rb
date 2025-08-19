# frozen_string_literal: true

class DotOne::AdvertiserBalances::Importer
  attr_accessor :upload, :errors

  def initialize(upload_id)
    @upload = Upload.find(upload_id)
    @errors = []
  end

  def import
    update_upload_status do
      upload.csv_rows.each do |row|
        validate_network_exists(row)
        validate_date_fields(row)

        upsert_advertiser_balance(row)
      rescue DotOne::Errors::BaseError => e
        errors << e.full_message
        next
      end
    rescue StandardError => e
      errors << e.message
    end
  end

  private

  def update_upload_status
    upload.update(status: Upload.status_in_progress)

    yield

    attrs =
      if errors.present?
        { status: Upload.status_error, error_details: errors.uniq.join("\n") }
      else
        { status: Upload.status_ready, error_details: nil }
      end

    @upload.update(attrs)
  end

  def validate_network_exists(row)
    network = Network.where(id: [row[:network_id], row[:advertiser_id]]).first
    raise DotOne::Errors::AccountError.new(row, 'account.advertiser_not_found') if network.blank?
  end

  def validate_date_fields(row)
    # Make sure data is sanitized
    [:recorded_at, :recorded_at_local, :invoice_date, :invoice_date_local].each do |key|
      DotOne::Utils.to_date(row[key]) if row[key].present?
    rescue StandardError
      raise DotOne::Errors::InvalidDataError.new(row, 'data.invalid_date_format', key)
    end
  end

  def notes(row)
    # Notes contains string that might be generated from
    # Excel of Windows - which the system had problem
    # converting chinese characters to UTF-8
    row[:notes].to_s
  end

  def upsert_advertiser_balance(row)
    existing_balance = AdvertiserBalance.find_or_initialize_by(id: row[:id])
    existing_balance.assign_attributes(payment_parameters(row))
    return if existing_balance.save

    raise DotOne::Errors::RecordValidationError.new(
      row, existing_balance
    )
  end

  def payment_parameters(row)
    tax = row[:sales_tax] || row[:tax]
    network_id = row[:network_id] || row[:advertiser_id]

    payment_parameters = {
      credit: row[:credit],
      debit: row[:debit],
      tax: tax,
      network_id: network_id,
      invoice_number: row[:invoice_number],
      invoice_amount: row[:invoice_amount],
      invoice_date_local: row[:invoice_date_local],
      invoice_date: row[:invoide_date],
      record_type: row[:record_type],
      notes: notes(row),
    }

    [:recorded_at_local, :recorded_at].each do |key|
      payment_parameters[key] = row[key] if row[key].present?
    end

    payment_parameters
  end
end
