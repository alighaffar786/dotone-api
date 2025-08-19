class DotOne::AffiliateStats::Importer
  attr_reader :upload, :user_role, :ability, :rows

  def initialize(upload_id, options = {})
    @upload = Upload.find(upload_id)
    @ability = Ability.new(@upload.owner)
    # Pass thru info about the user role that this upload is carried under
    @user_role = options[:user_role]
    @user_role ||= @upload.owner.generic_role rescue :network
    @trace_agent_via = "CSV Upload #{upload_id} - #{upload_type_name}"
    @upload_type = options[:upload_type] || 'NetworkOffer'

    # Record all detected errors
    @errors = []

    # Record all detected warnings
    @warnings = []

    @rows = generate_rows
  end

  def doc_url
    if user_role == :owner
      DotOne::ClientRoutes.admin_uploads_url
    else
      DotOne::ClientRoutes.advertisers_uploads_url
    end
  end

  def generate_rows
    result = upload.csv_rows
    if user_role == :owner
      result.take(5000)
    else
      result.take(1000)
    end
  rescue CSV::MalformedCSVError => e
    error = DotOne::Errors::UploadError.new(upload, 'upload.invalid_csv_file', doc_url: doc_url)
    log_errors(error.full_message)
    []
  rescue Encoding::UndefinedConversionError => e
    error = DotOne::Errors::UploadError.new(upload, 'upload.invalid_encoding', doc_url: doc_url)
    log_errors(error.full_message)
    []
  end

  # Hash to map transaction id with the
  # rest of the upload data
  def do_import
    rows.each_slice(500).each do |batch|
      warnings, errors = batch_klass.process(batch, ability: ability, trace_agent_via: @trace_agent_via)

      log_warnings(warnings)
      log_errors(errors)
    end
  end

  def import
    result = { upload_done: false, upload: upload }

    import_started
    do_import
    import_finished

    result.merge(
      upload_done: true,
      errors: @errors,
      success_rows: success_rows,
    )
  end

  private

  def batch_klass
    case @upload_type
    when 'NetworkOffer'
      Batch::NetworkOffer
    when 'EventOffer'
      Batch::EventOffer
    else
      raise ArgumentError, "Unknown upload type: #{@upload_type}"
    end
  end

  def upload_type_name
    case @upload_type
    when 'NetworkOffer'
      'Offer'
    when 'EventOffer'
      'Event'
    end
  end

  def import_started
    upload.update_column(:status, Upload.status_in_progress)
  end

  def import_finished
    if @errors.present?
      upload.status = Upload.status_error
    elsif @warnings.present?
      upload.status = Upload.status_warning
    else
      upload.status = Upload.status_ready
    end

    success_message = I18n.t('success.messages.rows_approved', rows: success_rows)
    upload.error_details = [success_message, *@errors, *@warnings].compact_blank.uniq.join("\n").presence
    upload.save!
  rescue ActiveRecord::ValueTooLong
    upload.upload_error_details
    upload.save!
  end

  def log_warnings(warnings)
    return @warnings if warnings.blank?

    @warnings = [@warnings, warnings].flatten
    @warnings
  end

  def log_errors(errors)
    return @errors if errors.blank?

    @errors = [@errors, errors].flatten
    @errors
  end

  def success_rows
    @success_rows ||= @rows.size - @warnings.size - @errors.size
  end
end
