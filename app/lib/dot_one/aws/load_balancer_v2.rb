class DotOne::Aws::LoadBalancerV2
  include DotOne::Aws::Credential
  include DotOne::Aws::ResponseHandler

  def client
    @client ||= Aws::ElasticLoadBalancingV2::Client.new(
      credentials: get_credentials,
    )
  end

  def list(arns)
    handle_response do
      resp = client.describe_load_balancers(
        load_balancer_arns: [arns].flatten,
      )

      resp.load_balancers
    end
  end

  def get(name)
    list(name).try(:first)
  end

  def create(params = {})
    handle_response do
      resp = client.create_load_balancer({
        type: 'application',
        scheme: 'internet-facing',
        subnets: [
          'subnet-03c35e546007c95ed',
          'subnet-063022b88db7d94e7',
          'subnet-0e0b9268dfe001f1b',
          'subnet-0f0806d53959d2dee',
        ],
        name: params[:name],
      })

      resp.load_balancers.first
    end
  end

  def delete(arn)
    handle_response do
      client.delete_load_balancer({
        load_balancer_arn: arn,
      })
    end
  end

  def create_target_group(params = {})
    handle_response do
      resp = client.create_target_group(
        name: params[:name],
        protocol: 'HTTP',
        port: 80,
        vpc_id: 'vpc-0d3d79a809b04553d',
      )

      resp.target_groups.first
    end
  end

  def delete_target_group(arn)
    handle_response do
      client.delete_target_group({
        target_group_arn: arn
      })
    end
  end

  def modify_target_group(params = {})
    handle_response do
      client.modify_target_group(
        target_group_arn: params[:target_group_arn],
        health_check_interval_seconds: 30,
        health_check_timeout_seconds: 15,
        healthy_threshold_count: 2,
        unhealthy_threshold_count: 5,
        health_check_path: '/ping',
      )
    end
  end

  def create_listeners(params = {})
    handle_response do
      https_listener = client.create_listener(
        default_actions: [
          {
            target_group_arn: params[:target_group_arn],
            type: 'forward',
          }
        ],
        certificates: [
          {
            certificate_arn: params[:certificate_arn],
          }
        ],
        load_balancer_arn: params[:load_balancer_arn],
        port: 443,
        protocol: 'HTTPS',
      )

      http_listener = client.create_listener(
        default_actions: [
          {
            target_group_arn: params[:target_group_arn],
            type: 'forward',
          },
        ],
        load_balancer_arn: params[:load_balancer_arn],
        port: 80,
        protocol: 'HTTP',
      )


      {
        listener_http_arn: http_listener.listeners.first.listener_arn,
        listener_https_arn: https_listener.listeners.first.listener_arn,
      }
    end
  end

  def get_listeners(load_balancer_arn)
    handle_response do
      client.describe_listeners(load_balancer_arn: load_balancer_arn).listeners
    end
  end

  def delete_listener(listener_arn)
    handle_response do
      client.delete_listener(listener_arn: listener_arn)
    end
  end
end
