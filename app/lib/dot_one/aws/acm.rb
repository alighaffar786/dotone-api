class DotOne::Aws::Acm
  include DotOne::Aws::Credential
  include DotOne::Aws::ResponseHandler

  attr_reader :client

  def client
    @client ||= Aws::ACM::Client.new(
      credentials: get_credentials,
    )
  end

  def poll_validation(certificate_arn)
    handle_response do
      poller = client.wait_until(:certificate_validated, { certificate_arn: certificate_arn }, {
        max_attempts: 3,
        delay: 60,
      })

      poller.certificate.domain_validation_options
    end
  end

  def list
    handle_response do
      resp = client.list_certificates
      resp.certificate_summary_list
    end
  end

  def create(params = {})
    handle_response do
      client.request_certificate({
        domain_name: params[:domain_name],
        idempotency_token: params[:idempotency_token],
        subject_alternative_names: [params[:alternative_names]].flatten,
        validation_method: 'DNS',
        options: {
          certificate_transparency_logging_preference: 'ENABLED',
        },
      })
    end
  end

  def get(certificate_arn)
    handle_response do
      client.get_certificate({
        certificate_arn: certificate_arn,
      })
    end
  end

  def describe(certificate_arn)
    handle_response do
      resp = client.describe_certificate({
        certificate_arn: certificate_arn,
      })

      resp.certificate
    end
  end

  def delete(certificate_arn, options = {})
    if options[:retry]
      retries = 1
      total_retries = options[:total_retries] || 5
      retry_delay = options[:retry_delay] || 10

      begin
        client.delete_certificate({
          certificate_arn: certificate_arn,
        })
      rescue Aws::ACM::Errors::ResourceInUseException
        if retries < total_retries
          sleep retry_delay
          retries += 1
          retry
        else
          delete(certificate_arn)
        end
      end
    else
      handle_response do
        client.delete_certificate({
          certificate_arn: certificate_arn,
        })
      end
    end
  end
end
