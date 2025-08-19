module DotOne::Aws::Credential
  def set_credentials
    Aws.config.update({
      region: 'us-east-1',
      credentials: get_credentials,
    })
  end

  def get_credentials
    Aws::Credentials.new(ENV.fetch('AWS_ROOT_ACCESS_KEY', nil), ENV.fetch('AWS_ROOT_SECRET_KEY', nil))
  end
end
