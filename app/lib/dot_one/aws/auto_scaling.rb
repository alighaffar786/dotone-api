class DotOne::Aws::AutoScaling
  include DotOne::Aws::Credential
  include DotOne::Aws::ResponseHandler

  def client
    @client ||= Aws::AutoScaling::Client.new(
      credentials: get_credentials,
    )
  end

  def list_groups(auto_scaling_group_names)
    handle_response do
      resp = client.describe_auto_scaling_groups({
        auto_scaling_group_names: [auto_scaling_group_names].flatten,
      })

      resp.auto_scaling_groups
    end
  end

  def list_load_balancers(auto_scaling_group_name)
    handle_response do
      resp = client.describe_load_balancers({
        auto_scaling_group_name: auto_scaling_group_name,
      })

      resp.load_balancers
    end
  end

  def attach_load_balancers(params = {})
    handle_response do
      client.attach_load_balancer_target_groups({
        auto_scaling_group_name: params[:auto_scaling_group_name],
        target_group_arns: [params[:target_group_arns]].flatten,
      })
    end
  end

  def detach_load_balancers(params = {})
    handle_response do
      client.detach_load_balancer_target_groups({
        auto_scaling_group_name: params[:auto_scaling_group_name],
        target_group_arns: [params[:target_group_arns]].flatten,
      })
    end
  end
end
