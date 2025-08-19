module Api::V2::SerializerHandler
  include Api::SerializerHandler

  protected

  def meta_options
    {
      meta: {
        locale: current_locale,
        currency: current_currency_code,
        time_zone: current_gmt,
        api_key: api_key&.value
      },
    }
  end
end
