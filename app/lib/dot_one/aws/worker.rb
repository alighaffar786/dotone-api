module DotOne::Aws
  require_relative 'ec2_image'
  require_relative 'ec2_auto_scaling'

  class Worker
    include DotOne::Aws::Ec2Image
    include DotOne::Aws::Ec2AutoScaling

    def initialize
      set_credentials
    end

    def go_live!
      puts 'Creating new AMI: '
      result = create_ami
      puts "New Image: #{result[:name]} (#{result[:image].id})"

      puts '=========='

      puts 'Creating new Launch Configuration: '
      launch_configuration_name = create_launch_configuration(result[:image])
      puts "New Launch Configuration Name: #{launch_configuration_name}"

      puts '=========='

      puts 'Attaching Launch Configuration to Auto Scaling Groups: '
      auto_scaling_groups = attach_launch_configuration_to_groups(launch_configuration_name)

      auto_scaling_groups.each do |group_description|
        puts "Auto Scaling Group #{group_description[:group_name]} is set to capacity: #{group_description[:desired_capacity]}"
      end

      puts '=========='

      puts 'Making Sure Load Balancers are Active: '
      wait_until_load_balancers_active(auto_scaling_groups)
      # refresh_instances(auto_scaling_groups)
    end

    def ec2_resource_client
      @ec2_resource_client ||= Aws::EC2::Resource.new
    end

    def ec2_auto_scaling_client
      @ec2_auto_scaling_client ||= Aws::AutoScaling::Client.new
    end

    def ec2_client
      @ec2_client ||= Aws::EC2::Client.new
    end

    def ec2_load_balancing_client
      @ec2_load_balancing_client ||= Aws::ElasticLoadBalancing::Client.new
    end

    def ec2_load_balancing_client_v2
      @ec2_load_balancing_client_v2 ||= Aws::ElasticLoadBalancingV2::Client.new
    end

    private

    def set_credentials
      Aws.config.update(
        region: 'us-east-1',
        credentials: Aws::Credentials.new(
          ENV.fetch('AWS_ROOT_ACCESS_KEY', nil),
          ENV.fetch('AWS_ROOT_SECRET_KEY', nil),
        ),
      )
    end
  end
end
