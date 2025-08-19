module Api::Public::ResponseHandler
  include Api::Public::SerializerHandler

  def respond_with(resource, **options)
    respond_to do |format|
      if [:ok, 200, nil].include?(options[:status]) && resource.is_a?(Hash)
        resource.merge!(meta_options)
      end

      format.json { render json: resource, **options }
      format.xml { render xml: render_xml_resource(resource, **options) }
    end
  end
end
