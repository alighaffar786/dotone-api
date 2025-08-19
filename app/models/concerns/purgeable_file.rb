module PurgeableFile
  extend ActiveSupport::Concern

  included do
    cattr_accessor :disable_purgeable_file
    cattr_reader :purgeable_file_attributes

    after_commit :purge_previous_files, on: :update
    after_destroy :purge_files
  end

  module ClassMethods
    # implementation
    # set_purgeable_file_attributes [:avatar, :cover_photo]
    def set_purgeable_file_attributes(*attrs)
      class_variable_set(:@@purgeable_file_attributes, (purgeable_file_attributes.to_a | attrs))
    end
  end

  def purge_previous_files
    purge_objects(is_update: true)
  end

  def purge_files
    purge_objects(is_update: false)
  end

  def purge_objects(is_update:)
    return if self.class.disable_purgeable_file

    self.class.purgeable_file_attributes.each do |attribute|
      next if is_update && !send("#{attribute}_previously_changed?")

      file_url = is_update ? send("#{attribute}_previously_was") : send(attribute)

      next if file_url.blank?

      uri = URI.parse(file_url)
      object_key = uri.path
      object_key = object_key.sub('/', '') if object_key.starts_with?('/')

      next unless dotone_bucket?(object_key)
      next unless name = bucket_name(uri.host)

      bucket = Aws::S3::Bucket.new(name)

      object = bucket.object(object_key)
      object.delete if object.exists?
    end
  end

  def dotone_bucket?(path)
    path.starts_with?("#{Rails.env}/dotone")
  end

  def bucket_name(host)
    if host.nil? || host.match(ENV.fetch('AWS_S3_PRIVATE_BUCKET'))
      ENV.fetch('AWS_S3_PRIVATE_BUCKET')
    elsif host.match(/(#{ENV.fetch('CDN_HOST')}|#{ENV.fetch('AWS_S3_PUBLIC_BUCKET')})/)
      ENV.fetch('AWS_S3_PUBLIC_BUCKET')
    end
  end
end
