Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(
    ENV.fetch('AWS_ACCESS_KEY', nil),
    ENV.fetch('AWS_SECRET_KEY', nil),
  ),
})

S3_PRIVATE_BUCKET = Aws::S3::Resource.new.bucket(ENV.fetch('AWS_S3_PRIVATE_BUCKET', nil))
