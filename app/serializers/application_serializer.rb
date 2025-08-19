class ApplicationSerializer < ActiveModel::Serializer
  AUTH_MODEL_NAMES = [
    'Affiliate',
    'AffiliateOffer',
    'ConversionStep',
    'ImageCreative',
    'Network',
    'NetworkOffer',
    'OfferVariant',
    'TextCreative',
  ]

  AUTH_MODEL_NAMES.each do |model_name|
    define_method "can_read_#{ConstantProcessor.to_method_name(model_name)}?" do
      !!current_ability&.can?(:read, model_name.constantize)
    end
  end

  def self.public_api?
    self.name.include?('V2')
  end

  def self.model
    begin
      class_name = self.name.demodulize
      class_name.gsub('Serializer', '').constantize
    rescue
      self.name.gsub("::#{class_name}", '').split('::')[-1].constantize rescue nil
    end
  end

  def self.t_attribute(arg, **options)
    if (model.respond_to?(:dynamic_translatable_attributes) && model.dynamic_translatable_attributes.include?(arg)) ||
      (model.respond_to?(:flexible_translatable_attributes) && model.flexible_translatable_attributes.include?(arg))
      attribute "t_#{arg}", **options.merge(if: -> { options[:if] ? send(options[:if]) && affiliate_user? : affiliate_user? }) do
        if t_locale == 'default'
          object.send(arg)
        else
          object.send("t_#{arg}", t_locale)
        end
      end
    end
  end

  def self.attributes(*args)
    args.each do |arg|
      attribute arg
      t_attribute arg
    end
  end

  def self.original_attributes(*args)
    args.each do |arg|
      attribute "original_#{arg}" do
        object.send(arg)
      end
    end
  end

  def self.translatable_attributes(*args)
    args.each do |arg|
      define_method(arg) do
        if affiliate_user? &&
          (object.class.respond_to?(:dynamic_translatable_attributes) && object.class.dynamic_translatable_attributes.include?(arg) ||
          object.class.respond_to?(:flexible_translatable_attributes) && object.class.flexible_translatable_attributes.include?(arg))
          object.send(arg)
        else
          object.send("t_#{arg}")
        end
      end
    end
  end

  def self.forexable_attributes(*args)
    args.each do |arg|
      define_method(arg) do
        if forex_value = object["forex_#{arg}"]
          forex_value.to_f
        else
          object.send("forex_#{arg}", currency_code)
        end
      end
    end
  end

  def self.local_time_attributes(*args)
    args.each do |arg|
      define_method(arg) do
        date =  object.send("#{arg}_local", time_zone)
        return date&.to_s(:db) if self.class.public_api?

        date
      end
    end
  end

  def self.maskable_address_attributes(*args)
    args.each do |arg|
      define_method(arg) do
        if affiliate_user?
          object.send(arg)
        else
          object.send("masked_#{arg}")
        end
      end
    end
  end

  def self.maskable_attributes(*args)
    args.each do |arg|
      define_method(arg) do
        if affiliate_user?
          object.send(arg)
        else
          object.send("masked_#{arg}")
        end
      end
    end
  end

  def self.conditional_attributes(*args, **options)
    args.each do |arg|
      attribute(arg, **{ if: "#{arg}?".to_sym }.merge(options))
      t_attribute(arg, **{ if: "#{arg}?".to_sym }.merge(options))
    end
  end

  def self.user_config_attributes
    attribute :locale, if: :include_config?
    attribute :currency_code, key: :currency, if: :include_config?
    attribute :time_zone_gmt, key: :time_zone, if: :include_config?
    attribute :unique_token, if: -> { include_config? && affiliate? }
  end

  def type
    object.class.name
  end

  def affiliate?
    current_user&.is_a?(Affiliate)
  end

  def network?
    current_user&.is_a?(Network)
  end

  def partial_pro_network?
    network? && current_user.partial_pro?
  end

  def pro_network?
    network? && current_user.pro?
  end

  def regular_network?
    network? && current_user.regular?
  end

  def affiliate_user?
    current_user&.is_a?(AffiliateUser)
  end

  def include_config?
    false
  end

  def context_class
    instance_options[:serializer_context_class]
  end

  def full_scope?
    context_class.blank?
  end

  def full_scope_requested?
    instance_options[:full_scope]
  end

  def can_read?
    return false unless self.class.model
    !!current_ability&.can?(:read, self.class.model)
  end

  def can_read_object?
    !!current_ability&.can?(:read, object)
  end

  def current_user
    instance_options[:scope] if instance_options[:scope_name] == :current_user
  end

  def current_columns
    instance_options[:columns]
  end

  def column_requested?(column)
    current_columns.include?(column.to_sym)
  end

  private

  def current_ability
    instance_options[:current_ability]
  end

  def time_zone
    instance_options[:time_zone]
  end

  def currency_code
    instance_options[:currency_code]
  end

  def t_locale
    instance_options[:t_locale]
  end
end
