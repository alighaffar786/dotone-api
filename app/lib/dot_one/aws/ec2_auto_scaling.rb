module DotOne::Aws::Ec2AutoScaling
  def create_launch_configuration(image)
    raise 'Image is required when creating new launch configuration' if image.blank?

    today = DateTime.now.strftime('%Y%m%d-T%H%M%S')

    launch_configuration_name = "#{ENV.fetch('AWS_WORKER_LAUNCH_CONFIGURATION_NAME')}-#{today}"

    block_device_mappings = image.block_device_mappings.map(&:to_h)

    result = ec2_auto_scaling_client.create_launch_configuration(
      launch_configuration_name: launch_configuration_name,
      image_id: image.id,
      instance_type: ENV.fetch('AWS_WORKER_LAUNCH_CONFIGURATION_INSTANCE_TYPE'),
      key_name: 'vibrantads-com',
      security_groups: ENV.fetch('AWS_WORKER_LAUNCH_CONFIGURATION_SECURITY_GROUPS').split(','),
      iam_instance_profile: 'arn:aws:iam::964352350895:instance-profile/ec2-aws-elasticsearch',
      block_device_mappings: block_device_mappings,
    )

    launch_configuration_name
  end

  def attach_launch_configuration_to_groups(launch_configuration_name)
    to_return = []

    group_name = ENV.fetch('AWS_WORKER_AUTO_SCALING_GROUP')

    puts "  Adjusting Auto Scaling Group: #{group_name}:"

    desired_capacity = obtain_current_desired_capacity(group_name)
    new_desired_capacity = desired_capacity * (desired_capacity > 3 ? 2 : 4)

    while desired_capacity != new_desired_capacity
      puts "    Current Capacity: #{desired_capacity}  New Capacity: #{new_desired_capacity}"
      resp = ec2_auto_scaling_client.update_auto_scaling_group(
        auto_scaling_group_name: group_name,
        launch_configuration_name: launch_configuration_name,
        desired_capacity: new_desired_capacity,
      )
      desired_capacity = obtain_current_desired_capacity(group_name)
    end

    to_return << { group_name: group_name, desired_capacity: new_desired_capacity }

    to_return
  end

  def wait_until_load_balancers_active(groups)
    groups.each do |group_description|
      group_name = group_description[:group_name]
      desired_capacity = group_description[:desired_capacity]

      load_balancer_names = obtain_load_balancers_from_group(group_name)

      load_balancer_names.each do |lb_name|
        instance_size = obtain_instance_size_from_load_balancer(lb_name)
        puts "  Check Load Balancer #{lb_name} Instance Size: "
        while instance_size != desired_capacity
          puts "    (Instance Size: #{instance_size}) (Desired Size: #{desired_capacity})"
          sleep(2)
          instance_size = obtain_instance_size_from_load_balancer(lb_name)
        end
        puts '  Instance Size - OK'

        instance_states = obtain_instance_states_from_load_balancer(lb_name)
        instance_health = instance_states.map { |x| x[:state] }
        puts "  Check Load Balancer #{lb_name} Instance Health: "

        until are_all_in_service?(instance_health)
          instance_states.each do |instance_state|
            puts "   Instance: #{instance_state[:instance_id]}  State: #{instance_state[:state]}"
          end
          sleep(4)
          instance_states = obtain_instance_states_from_load_balancer(lb_name)
          instance_health = instance_states.map { |x| x[:state] }
        end
        puts '  Instance Health - OK'
      end
    end
  end

  def obtain_current_desired_capacity(group_name)
    result = ec2_auto_scaling_client.describe_auto_scaling_groups(
      auto_scaling_group_names: [group_name],
    )

    group_description = result[:auto_scaling_groups][0]

    group_description[:desired_capacity]
  end

  def obtain_load_balancers_from_group(group_name)
    result = ec2_auto_scaling_client.describe_load_balancers(
      auto_scaling_group_name: group_name,
    )

    load_balancer_names = result[:load_balancers].map(&:load_balancer_name)

    if load_balancer_names.blank?
      result = ec2_auto_scaling_client.describe_load_balancer_target_groups(
        auto_scaling_group_name: group_name,
      )

      target_groups = result[:load_balancer_target_groups].map(&:load_balancer_target_group_arn)

      load_balancers = []

      loop do
        break if target_groups.blank?

        result = ec2_load_balancing_client_v2.describe_target_groups(
          target_group_arns: target_groups.shift(20),
        )

        load_balancers += result[:target_groups].map(&:load_balancer_arns).flatten
      end

      loop do
        break if load_balancers.blank?

        result = ec2_load_balancing_client_v2.describe_load_balancers(
          load_balancer_arns: load_balancers.shift(20),
        )

        load_balancer_names += result[:load_balancers].map(&:load_balancer_name)
      end
    end

    load_balancer_names
  end

  def obtain_instance_size_from_load_balancer(load_balancer_name)
    instance_size = 0

    begin
      result = ec2_load_balancing_client.describe_instance_health(
        load_balancer_name: load_balancer_name,
      )
      instance_size = result[:instance_states].length
    rescue StandardError => e
      target_groups = obtain_target_groups_from_load_balancer(load_balancer_name)

      target_groups.each do |tg_arn|
        result = ec2_load_balancing_client_v2.describe_target_health(
          target_group_arn: tg_arn,
        )
        instance_size += result[:target_health_descriptions].length
      end
    end

    instance_size
  end

  def obtain_instance_states_from_load_balancer(load_balancer_name)
    instance_states = []

    begin
      result = ec2_load_balancing_client.describe_instance_health(
        load_balancer_name: load_balancer_name,
      )

      instance_states = result[:instance_states]
    rescue StandardError => e
      target_groups = obtain_target_groups_from_load_balancer(load_balancer_name)

      target_groups.each do |tg_arn|
        result = ec2_load_balancing_client_v2.describe_target_health(
          target_group_arn: tg_arn,
        )

        result[:target_health_descriptions].each do |description|
          instance_states << {
            state: description.target_health.state,
            instance_id: description[:target][:id],
          }
        end
      end
    end

    instance_states
  end

  def obtain_target_groups_from_load_balancer(load_balancer_name)
    result = ec2_load_balancing_client_v2.describe_load_balancers(
      names: [load_balancer_name],
    )
    lb_arn = result[:load_balancers][0].load_balancer_arn

    result = ec2_load_balancing_client_v2.describe_target_groups(
      load_balancer_arn: lb_arn,
    )

    result[:target_groups].map(&:target_group_arn)
  end

  def are_all_in_service?(instance_health)
    instance_health.size == instance_health.select { |x| ['InService', 'healthy'].include? x }.length
  end

  def refresh_instances(groups)
    groups.each do |group|
      ec2_auto_scaling_client.start_instance_refresh(auto_scaling_group_name: group[:group_name])
    end
  end
end
