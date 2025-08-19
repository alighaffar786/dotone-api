module Api::Client::ResponseHandler
  include Api::SerializerHandler

  protected

  def respond_with(resource, **options)
    case options[:status]
    when :unprocessable_entity, 422
      if resource.respond_to?(:errors)
        render json: { message: resource.errors }, **options
      else
        render json: resource, **options
      end
    else
      if resource.is_a?(Hash) || (resource.is_a?(Array) && !options[:each_serializer])
        options = options.except(:serializer, :each_serializer).deep_merge(meta_options)

        if options.key?(:status) && options[:status] != 200 && resource.is_a?(Hash)
          render json: resource, **options
        else
          render json: { data: resource, **options }
        end
      else
        render json: resource, **options
      end
    end
  end

  def respond_with_pagination(collection, **options)
    options_with_pagination = options.deep_merge(meta_pagination(collection))

    collection = yield(collection.where(id: collection.map(&:id)).except(:offset, :limit)) if block_given?

    render json: collection, **options_with_pagination
  end
end
