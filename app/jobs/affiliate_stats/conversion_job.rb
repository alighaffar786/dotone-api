# frozen_string_literal: true

class AffiliateStats::ConversionJob < TrackingJob
  def perform(affiliate_stat_id, conversion_options, process_options = nil, raw_request = nil)
    sanitized_stat_id = AffiliateStat.sanitize_stat_id(affiliate_stat_id)

    begin
      stat = AffiliateStat.find(sanitized_stat_id)
    rescue ActiveRecord::RecordNotFound => e
      stat = AffiliateStat.find_by_valid_subid(sanitized_stat_id)

      if stat.present?
        recorded_at = Postback.where(affiliate_stat_id: affiliate_stat_id).where(raw_request: raw_request).order(recorded_at: :desc).first&.recorded_at

        if recorded_at.present?
          if process_options.present?
            process_options[:captured_at] ||= recorded_at
          else
            conversion_options[:captured_at] ||= recorded_at
          end
        end
      else
        raise e if stat.blank?
      end
    end

    raise "Snapshot not found for #{stat.id}" if stat.conversion_steps.blank?

    result = if process_options.present?
      stat.process_conversion!(conversion_options, process_options)
    else
      stat.process_conversion!(conversion_options)
    end

    error_message = result[:errors].join(', ')
    return unless error_message.present?

    DELAYED_CONVERSION_LOGGER.error "Stat ID: #{affiliate_stat_id}. ConversionOptions #{conversion_options}. ProcessOptions: #{process_options}. Raw Request: #{raw_request}. Error: #{error_message}"
  rescue ActiveRecord::RecordNotFound => e
    DotOne::Services::MissingClickHandler.write(affiliate_stat_id)

    raise e
  end
end
