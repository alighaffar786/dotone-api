module Api::V2::ResponseHandler
  include Api::V2::SerializerHandler

  def respond_with(resource, **options)
    respond_to do |format|
      if [:ok, 200, nil].include?(options[:status]) && resource.is_a?(Hash)
        resource.merge!(meta_options)
      end

      format.json { render json: resource, **options }
      format.xml { render xml: render_xml_resource(resource, **options) }
    end
  end

  def respond_with_pagination(collection, **options)
    respond_to do |format|
      options = options.deep_merge(meta_pagination(collection))

      format.json { render json: collection, **options }
      format.xml { render xml: render_xml_resource(collection, **options) }
    end
  end

  def render_xml_resource(resource, **options)
    data = if resource.is_a?(Hash) && resource.key?(:message)
      resource
    else
      get_serializer(resource, **options).serializable_hash
    end

    data.to_xml
  end
end
