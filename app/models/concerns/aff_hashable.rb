module AffHashable
  extend ActiveSupport::Concern
  include BooleanHelper

  included do
    cattr_reader :predefined_flag_attributes

    has_one :aff_hash, as: :entity, dependent: :destroy, autosave: true

    attr_accessor :flag_changed

    before_save :clear_empty_flags
    after_save :save_flags
  end

  module ClassMethods
    ##
    # Class method to assign a predefined flag attributes
    # so it can convenient used as follow:
    # Example: instance_object.flag_original_price
    # where instance_object's class has :original_price as the args
    # to this method.
    def set_predefined_flag_attributes(*args, **options)
      class_variable_set(:@@predefined_flag_attributes, predefined_flag_attributes.to_a | args)

      flag_type = options[:type] || :text

      args.each do |flag_attr|
        define_method(flag_attr) do
          value = flag(flag_attr)

          if flag_type == :boolean
            truthy?(value)
          elsif flag_type == :float
            value.presence.to_f
          elsif flag_type == :integer
            value.presence.to_i
          elsif flag_type == :json
            begin
              value.present? ? JSON.parse(value).with_indifferent_access : nil
            rescue JSON::ParserError
              nil
            end
          else
            value
          end
        end

        define_method("flag_#{flag_attr}") do
          send(flag_attr)
        end

        if flag_type == :boolean
          define_method("#{flag_attr}?") do
            send(flag_attr)
          end
        end

        define_method("flag_#{flag_attr}=") do |value|
          new_value =
            if flag_type == :boolean
              truthy?(value) ? 1 : 0
            elsif flag_type == :float
              value.to_f
            elsif flag_type == :integer
              value.to_i
            elsif flag_type == :json
              value.present? ? value.to_json : nil
            elsif value.is_a?(Hash)
              convert = ->(obj) do
                if obj.is_a?(Hash)
                  obj.keys.each do |key|
                    v = obj[key]
                    if v.is_a?(Hash)
                      obj[key] = convert.call(v)
                    elsif v.is_a?(ActiveSupport::TimeWithZone)
                      # imitate Rails v3.2
                      obj[key] = v.to_time
                    end
                  end
                end

                obj
              end

              convert.call(value)
            else
              value
            end

          flag(flag_attr, new_value)
        end

        define_method("#{flag_attr}=") do |value|
          send("flag_#{flag_attr}=", value)
        end
      end
    end

    def predefined_system_flag_attributes(*args)
      args.each do |flag_attr|
        define_method("system_flag_#{flag_attr}") do
          system_flag(flag_attr)
        end

        define_method("system_flag_#{flag_attr}=") do |par|
          system_flag(flag_attr, par)
        end
      end
    end
  end

  def predefined_flags
    flags.select { |flag| predefined_flag?(flag[:key]) }
  end

  def hash_tokens
    flags.reject { |flag| predefined_flag?(flag[:key]) }
  end

  def hash_tokens=(values)
    new_flags = predefined_flags + values.reject { |val| predefined_flag?(val[:key]) }
    self.flags = new_flags
  end

  def system_flag(*args)
    handle_flag_access(:system_flag, *args)
  end

  def flag(*args)
    handle_flag_access(:flag, *args)
  end

  def flag_changed?
    flag_changed
  end

  def save_flags
    return if aff_hash.blank? || (aff_hash.present? && aff_hash.flag.blank? && aff_hash.system_flag.blank?)

    aff_hash.flag = AffHash.hash_array_to_hash(flags)
    aff_hash.save
  end

  def flags
    return [] if flag.blank?

    flag.keys.map do |key|
      {
        key: key,
        value: flag(key),
      }
    end
  end

  def flags=(flag_array)
    self.aff_hash ||= build_aff_hash(flag: {}, system_flag: {})
    aff_hash.flag = AffHash.hash_array_to_hash(flag_array)
    self.flag_changed = true
  end

  private

  def clear_empty_flags
    aff_hash&.mark_for_destruction if flag.blank? && system_flag.blank?
  end

  def predefined_flag?(key)
    self.class.predefined_flag_attributes&.include?(key.to_sym)
  end

  ##
  # Refactor flag store and read operations
  def handle_flag_access(attribute_type, *args)
    if args.length == 2
      self.aff_hash ||= build_aff_hash(flag: {}, system_flag: {})
      self.flag_changed = true
      aff_hash.set(attribute_type, args[0].to_s.strip, args[1])
    elsif args.length == 1
      if respond_to?(:cached_aff_hash)
        cached_aff_hash&.get(attribute_type, args[0])
      else
        aff_hash&.get(attribute_type, args[0])
      end
    else
      if respond_to?(:cached_aff_hash)
        cached_aff_hash&.send(attribute_type)
      else
        aff_hash&.send(attribute_type)
      end
    end
  end
end
