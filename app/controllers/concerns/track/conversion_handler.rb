module Track::ConversionHandler
  include BooleanHelper

  def postback_retrigger?
    truthy?(params[:postback_retrigger])
  end

  def convert_this(stat_id, options = {})
    if DotOne::Setup.db_on? && falsy?(options[:delayed]) && affiliate_stat = AffiliateStat.find_by_id(stat_id)
      affiliate_stat.process_conversion!(options.merge(params.permit!))
    else
      convert_delayed(stat_id, options)
    end
  rescue Exception => e
    Sentry.capture_exception(e)
    convert_delayed(stat_id, options)
  end

  def convert_delayed(stat_id, options = {})
    kinesis_options = {
      stat_id: stat_id,
      options: options,
      params: params.permit!,
      request_string: raw_request,
    }
    queued = DotOne::Kinesis::Client.to_kinesis(DotOne::Kinesis::TASK_PROCESS_CONVERSION, {}, kinesis_options)
    { convert: queued ? :delayed : false }
  end

  def raw_request
    result = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    post_params = request.raw_post.presence
    request_method = "#{request.method}2"

    if post_params
      if result.include?("?")
        result = "#{result}&#{post_params}"
      else
        result = "#{result}?#{post_params}"
      end
    end

    if request_method
      if result.include?("?")
        result = "#{result}&method_detected=#{request_method}"
      else
        result = "#{result}?method_detected=#{request_method}"
      end
    end

    result
  end

  def save_postback(response, affiliate_stat_id)
    return if postback_retrigger?

    stat_id = AffiliateStat.sanitize_stat_id(affiliate_stat_id.to_s).presence || "Unknown-#{request.remote_ip}"

    kinesis_options = {
      affiliate_stat_id: stat_id,
      raw_request: raw_request,
      raw_response: response.to_s,
      postback_type: Postback.postback_type_incoming,
      recorded_at: Time.now,
      ip_address: request.remote_ip,
    }

    DotOne::Kinesis::Client.to_kinesis(DotOne::Kinesis::TASK_SAVE_POSTBACK, {}, kinesis_options)
  end
end
