class DotOne::AffiliateStats::Importer::RowValidator
  DATE_COLUMNS = [:recorded_at, :captured_at, :published_at, :converted_at]
  FLOAT_COLUMNS = [:true_pay, :affiliate_pay, :order_total, :true_share, :affiliate_share]
  BOOLEAN_COLUMNS = [:is_payment_received, :skip_approved_transaction, :skip_date_validation, :allow_zero]

  attr_reader :original, :data, :user_role

  def initialize(data, options = {})
    @user_role = options[:user_role]
    @original = data.with_indifferent_access
    @data = cleanup(@original)
  end

  def cleanup(data)
    new_data = data.transform_values { |value| value ? value.strip : value }

    BOOLEAN_COLUMNS.each do |column|
      new_data[column] = new_data[column].to_s.downcase
    end

    unless user_role == :owner
      data.except!(
        :is_payment_received,
        :skip_set_to_published,
        :allow_zero,
        :published_at,
        :converted_at,
        :affiliate_pay,
        :affiliate_share,
      )
    end

    data
  end

  # Check order_total, true_pay and affiliate_pay
  def validate_float_fields
    FLOAT_COLUMNS.each do |column|
      Float(data[column]) if data[column].present?
    rescue Exception => e
      raise DotOne::Errors::InvalidDataError.new(original, 'data.invalid_number', column)
    end
  end

  def validate_approval
    if data[:approval].present? && AffiliateStat.approvals.exclude?(data[:approval])
      raise DotOne::Errors::InvalidDataError.new(original, 'data.invalid_string', 'approval')
    end
  end

  def validate_current_approval
    if data[:current_approval].present? && AffiliateStat.approvals.exclude?(data[:current_approval])
      raise DotOne::Errors::InvalidDataError.new(original, 'data.invalid_string', 'current_approval')
    end
  end

  def validate_boolean_fields
    BOOLEAN_COLUMNS.each do |column|
      if data[column].present? && ['yes', 'no'].exclude?(data[column])
        raise DotOne::Errors::InvalidDataError.new(original, 'data.invalid_string', column)
      end
    end
  end

  # Check any required columns
  def validate_required_fields
    if data[:order_number].blank? && data[:id].blank?
      raise DotOne::Errors::InvalidDataError.new(original, 'data.missing_value', 'id and order_number')
    end

    if data[:order_number].present? && data[:id].blank? && data[:offer_id].blank? && data[:affiliate_id].blank?
      raise DotOne::Errors::InvalidDataError.new(original, 'data.missing_value', 'offer_id or id or affiliate_id')
    end
  end

  # Check date format
  def validate_date_fields
    DATE_COLUMNS.each do |column|
      if data[column].present? && date = DotOne::Utils.to_datetime("#{data[column]} 08:00:00")
        if !BooleanHelper.truthy?(data[:skip_date_validation]) && (date < 1.year.ago.beginning_of_year || date > 1.year.from_now.beginning_of_year)
          raise DotOne::Errors::InvalidDataError.new(data, 'data.invalid_date_format', data[column])
        end

        if [:published_at, :converted_at].include?(column) &&
          !DotOne::Utils.date_convertable?(date) &&
          AffiliateStat.approvals_considered_approved(user_role).include?(data[:approval])
          raise DotOne::Errors::InvalidDataError.new(data, 'data.approval_date_is_invalid', DotOne::Utils.earliest_conversion_date.to_date)
        end

        @data[column] = TimeZone.current.to_utc(date)
      end
    rescue Exception => e
      if e.class == DotOne::Errors::InvalidDataError
        raise e
      else
        raise DotOne::Errors::InvalidDataError.new(original, 'data.invalid_date_format', column)
      end
    end
  end

  ##
  # Routine to make sure all data is proper
  # and ready to upload
  def validate
    validate_float_fields
    validate_current_approval
    validate_approval
    validate_boolean_fields
    validate_required_fields
    validate_date_fields

    data
  end

  class EventOffer < DotOne::AffiliateStats::Importer::RowValidator
    def validate_required_fields
      if data[:true_pay].blank?
        raise DotOne::Errors::InvalidDataError.new(original, 'data.missing_value', 'true_pay')
      end

      if data[:affiliate_pay].blank?
        raise DotOne::Errors::InvalidDataError.new(original, 'data.missing_value', 'affiliate_pay')
      end
    end
  end

  class NetworkOffer < DotOne::AffiliateStats::Importer::RowValidator; end
end
