class DotOne::Aws::CloudFront
  include DotOne::Aws::Credential
  include DotOne::Aws::ResponseHandler

  def self.invalidate(items, options = {})
    new.invalidate(items, options)
  end

  def client
    @client ||= Aws::CloudFront::Client.new(
      credentials: get_credentials,
    )
  end

  def invalidate(items, options = {})
    handle_response do
      client.create_invalidation({
        distribution_id: ENV.fetch('AWS_CLOUDFRONT_DISTRIBUTION_ID', nil),
        invalidation_batch: {
          paths: {
            quantity: 1,
            items: [items].flatten,
          },
          caller_reference: options[:caller_reference] || "caller_reference_#{Time.now.to_i}",
        },
      })
    end
  end
end
