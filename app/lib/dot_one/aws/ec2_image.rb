module DotOne::Aws::Ec2Image
  def create_ami
    today = DateTime.now.strftime('%Y%m%d-T%H%M%S')
    image_name = "#{ENV.fetch('AWS_WORKER_IMAGE_NAME')}-#{today}"
    source_instance = get_ec2_instance_by_name(ENV.fetch('AWS_WORKER_INSTANCE_SOURCE_NAME'))
    raise 'No Source Instance' if source_instance.blank?

    image = source_instance.create_image(
      name: image_name,
      no_reboot: true,
    )

    image.wait_until_exists do
      while image.reload.state != 'available'
        sleep(2)
        puts "  Image #{image_name} is #{image.state}"
      end
      return { name: image_name, image: image }
    end
  end

  def get_ec2_instance_by_name(name)
    return if name.blank?

    to_return = nil

    ec2_resource_client.instances(
      filters: [{ name: 'tag:Name', values: [name] }],
    ).each do |instance|
      to_return = instance
    end

    to_return
  end
end
