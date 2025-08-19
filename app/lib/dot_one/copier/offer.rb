class DotOne::Copier::Offer
  attr_accessor :offer, :user, :result

  def initialize(offer, user)
    self.offer = offer
    self.user = user
  end

  def copy
    @result = offer.dup

    before_save

    if result.save
      result.reload
      after_save
    end

    result.reload if result.persisted?
    result
  end

  private

  def before_save
    num = 0
    loop do
      num += 1
      result.name = ["Copy of #{offer.id}", num > 1 ? "(#{num})" : nil].compact.join(' ')
      break unless Offer.exists?(name: result.name)
    end

    result.published_date = nil
  end

  def after_save
    result.owner_has_tags = offer.owner_has_tags.map(&:dup)
    result.category_ids = offer.category_ids
    result.country_ids = offer.country_ids
    result.term_ids = offer.term_ids

    offer.conversion_steps.each do |conversion_step|
      if conversion_step.is_default? && result.default_conversion_step.present?
        attributes = conversion_step.attributes.except('created_at', 'updated_at', 'offer_id', 'id')
        result.default_conversion_step.update(attributes)
      else
        new_conversion_step = conversion_step.dup
        new_conversion_step.offer_id = result.id
        new_conversion_step.save
      end
    end

    default_variant = offer.offer_variants.find(&:is_default?)
    attributes = default_variant.attributes.except('created_at', 'updated_at', 'offer_id', 'id')

    if result.default_offer_variant
      result.default_offer_variant.update(attributes.merge(status: OfferVariant.status_paused))
    else
      result.default_offer_variant = default_variant.dup.tap do |v|
        v.offer_id = result.id
        v.status = OfferVariant.status_paused
        v.save
      end
    end

    if (offer_cap = default_variant.offer_cap&.dup)
      offer_cap.offer_variant = result.default_offer_variant
      offer_cap.save
    end

    [nil, :small, :medium, :large].each do |variant|
      method_name = [:brand_image, variant].compact.join('_')
      cdn_url = offer.send("#{method_name}_url")

      next if cdn_url.blank?

      result.send("#{method_name}_url=", duplicate_file(cdn_url))
    end

    result.aff_hash&.update(flag: offer.aff_hash.flag)
    result.translations = offer.translations.map do |translate|
      Translation.new(translate.attributes.except('id', 'created_at', 'updated_at', 'unique_id'))
    end

    result.save
  end

  def duplicate_file(cdn_url)
    return if cdn_url.blank?

    bucket = Aws::S3::Bucket.new(ENV.fetch('AWS_S3_PUBLIC_BUCKET'))

    file = Tempfile.new
    URI.open(cdn_url) do |image|
      file.binmode
      file.write image.read
    end

    extension = File.extname(cdn_url)
    object_key = "#{image_object_path}#{SecureRandom.uuid}#{extension}"
    bucket.object(object_key).upload_file(file.path)

    file.unlink

    uri = URI(DotOne::Setup.cdn_url)
    uri.path = "/#{object_key}"
    uri.to_s
  rescue OpenURI::HTTPError
  end
end
