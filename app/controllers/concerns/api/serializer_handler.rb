module Api::SerializerHandler
  include CurrentHandler

  protected

  def get_serializer(resource, options = {})
    super(resource, options.merge(serializer_options).deep_merge(meta_options))
  end

  def serializer_options
    {
      locale: current_locale,
      currency_code: current_currency_code,
      time_zone: current_time_zone,
      t_locale: current_t_locale,
      columns: current_columns,
      current_ability: current_ability,
    }.merge(request.format.json? ? { root: :data } : {})
  end

  def pagination(collection)
    {
      page: collection.current_page,
      per_page: collection.per_page,
      total_entries: collection.total_entries,
    }
  end

  def meta_pagination(collection)
    {
      meta: { pagination: pagination(collection) },
    }
  end

  def meta_options
    {
      meta: {
        locale: current_locale,
        currency: current_currency_code,
        time_zone: current_gmt,
      },
    }
  end
end
