module Api::Public::SerializerHandler
  include Api::SerializerHandler

  protected

  def serializer_options
    puts "-------------------------"
    puts current_locale.inspect
    {
      locale: current_locale,
      t_locale: current_t_locale,
      columns: current_columns,
    }.merge(request.format.json? ? { root: :data } : {})
  end

  def meta_options
    puts "========================="
    puts current_locale.inspect
    {
      meta: {
        locale: current_locale,
      },
    }
  end
end

