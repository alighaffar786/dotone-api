module ConstantProcessor
  extend ActiveSupport::Concern

  RESERVED_KEYWORDS = [:new]

  def self.prepend_prefix(method_name, prefix: nil)
    return method_name.to_sym unless prefix

    [prefix, method_name].compact.join('_').to_sym
  end

  def self.to_method_name(value, prefix: nil, formatter: nil)
    method_name = value.to_s
      .gsub('/', '_')
      .convert_miscellaneous_characters
      .titleize
      .gsub(/\d+/) { |x| "_#{x}" }
      .replace_whitespace('')
      .underscore
    method_name = method_name.send(formatter) if formatter
    prepend_prefix(method_name, prefix: prefix).to_sym
  end

  def self.valid_method_name?(value)
    RESERVED_KEYWORDS.exclude?(value.to_sym)
  end

  module ClassMethods
    def define_constant_methods(values, column, **options)
      method_name = ConstantProcessor.to_method_name(column, prefix: options[:prefix], formatter: :pluralize)

      # Example:
      # def self.statuses
      #   ['Pending', 'Approved', 'Rejected', 'Confirming', 'Completed']
      # end
      define_singleton_method method_name do
        values
      end

      # Example:
      # scope :with_status, (*args) { where(status: args.flatten) if args.present? }
      scope "with_#{method_name}".to_sym, -> (*args) { where(column => args.flatten) if args[0].present? }

      values.each do |value|
        method_name = ConstantProcessor.to_method_name(value)
        method_name_with_prefix = ConstantProcessor.prepend_prefix(method_name, prefix: options[:prefix] || column)
        instance_method_name = ConstantProcessor.prepend_prefix(method_name, prefix: options[:prefix_instance])
        scope_name = ConstantProcessor.prepend_prefix(method_name, prefix: options[:prefix_scope])

        # Example:
        # scope :pending, -> { where(status: 'Pending') }
        # ...etc
        # Will not generate scope if method name is invalid
        scope scope_name, -> { where(column => value) } if !options[:skip_scope] && ConstantProcessor.valid_method_name?(scope_name)

        # Example:
        # def self.status_pending
        #   'Pending'
        # end
        # ...etc
        if method_defined?(method_name_with_prefix)
          puts "skipped define method `#{method_name_with_prefix}`"
        else
          define_singleton_method method_name_with_prefix do
            value
          end
        end

        # Example:
        # def pending?
        #   status == 'Pending'
        # end
        # ...etc
        if method_defined?("#{instance_method_name}?")
          puts "skipped define method `#{instance_method_name}?`"
        else
          define_method "#{instance_method_name}?" do
            send(column) == value
          end
        end
      end
    end
  end
end
