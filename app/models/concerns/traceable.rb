module Traceable
  extend ActiveSupport::Concern

  TRACES_PER_PAGE = 20

  included do
    attr_accessor :trace_custom_agent

    after_create :trace_create
    after_update :trace_update
  end

  module ClassMethods
    def trace_as_date(*args)
      class_eval do
        class << self
          attr_accessor :trace_date_attributes
        end
        @trace_date_attributes = args
      end
    end

    def trace_ignorable(*args)
      class_eval do
        class << self
          attr_accessor :trace_ignorable_attributes
        end
        @trace_ignorable_attributes = args
      end
    end

    def trace_has_many_includes(*args)
      class_eval do
        class << self
          attr_accessor :trace_has_many_includes_attributes
        end
        @trace_has_many_includes_attributes = args
      end
    end

    def trace_has_one_includes(*args)
      class_eval do
        class << self
          attr_accessor :trace_has_one_includes_attributes
        end
        @trace_has_one_includes_attributes = args
      end
    end
  end

  def trace_name
    val = nil
    [:name_to_trace, :id_with_name, :id_with_number, :id].each do |mtd|
      if methods.include?(mtd)
        val = send(mtd)
        break
      end
    end
    val
  end

  def traces(verb = nil, current_page = 1, per_page = TRACES_PER_PAGE, options = {})
    includes_has_many_attributes = begin
      self.class.trace_has_many_includes_attributes
    rescue StandardError
      []
    end
    includes_has_one_attributes = begin
      self.class.trace_has_one_includes_attributes
    rescue StandardError
      []
    end
    Trace.for_entity(self, {
      has_many: {
        include: includes_has_many_attributes,
        exclude: options[:exclude_has_many],
      },
      has_one: {
        include: includes_has_one_attributes,
        exclude: options[:exclude_has_one],
      },
    })
      .with_verb(verb).order('created_at DESC, id DESC')
      .paginate(page: current_page, per_page: per_page)
  end

  def trace!(verb, options = {})
    ignored_attributes = [:updated_at, :created_at]
    begin
      ignored_attributes << self.class.trace_ignorable_attributes
    rescue StandardError
      []
    end
    ignored_attributes.flatten!
    trace_changes = options[:changes]
    if trace_changes.blank?
      trace_changes = saved_changes.reject do |attribute, _values|
        ignored_attributes.include?(attribute.to_sym)
      end
    end
    custom_changes = options[:changes].present?

    trace_changes = normalize_changes(trace_changes)

    return if trace_changes.blank?

    t = Trace.new

    # agent
    if options[:custom_agent].present?
      t.agent = options[:custom_agent]
    elsif DotOne::Current.user.present?
      t.agent = begin
        "#{DotOne::Current.user.class.model_name.human}: #{DotOne::Current.user.trace_name}"
      rescue StandardError
      end
      t.agent = "#{DotOne::Current.user.class.model_name.human} ID: #{DotOne::Current.user.id}" if t.agent.blank?
      t.agent_id = DotOne::Current.user.id
      t.agent_type = DotOne::Current.user.class.name
    else
      t.agent = 'System'
    end

    # verb
    t.verb = verb.to_s

    # target
    t.target_id = id
    t.target_type = self.class.name
    target_string = []
    target_string << 'New' if t.target_id.blank?

    if respond_to?(:trace_string)
      target_string << trace_string
    else
      target_string << self.class.model_name.human
      target_string << "ID #{t.target_id}" if t.target_id.present?
    end

    t.target = target_string.compact.join(' ')

    # notes
    trace_notes = []
    if custom_changes
      trace_notes = generate_custom_notes(trace_changes)
    else
      trace_changes.each_pair do |attribute, array|
        trace_notes << "#{self.class.human_attribute_name(attribute)}:"
        date_attributes = begin
          self.class.trace_date_attributes
        rescue StandardError
          []
        end
        if date_attributes.include?(attribute.to_sym)
          old_value = begin
            TimeZone.current.from_utc(array.first).to_date.to_s
          rescue StandardError
          end
          new_value = begin
            TimeZone.current.from_utc(array.last).to_date.to_s
          rescue StandardError
          end
          trace_notes << [array_to_string([old_value, new_value]), '.'].join
        else
          trace_notes << [array_to_string(array), '.'].join
        end
      end
    end
    t.notes = trace_notes.join(' ')
    t.save!
  end

  def trace_create
    trace!('creates', { custom_agent: trace_custom_agent })
  rescue StandardError
  end

  def trace_update
    trace!('updates', { custom_agent: trace_custom_agent })
  rescue StandardError
  end

  def trace_agent_via=(via)
    return if via.blank?

    via_str = "(via #{via})"

    if current_user = DotOne::Current.user
      current_role_name = DotOne::Current.user&.roles
      self.trace_custom_agent = "#{current_role_name}: #{current_user.id_with_name} #{via_str}"
    else
      self.trace_custom_agent = "System #{via_str}"
    end
  end

  private

  def generate_custom_notes(changes)
    change_string = []
    changes.each_pair do |key, value|
      change = array_to_string(value)
      change_string << "#{key}: #{change}." if change.present?
    end
    change_string
  end

  def array_to_string(arr)
    "#{arr.first} => #{arr.last}"
  end

  # Helper method to standardize
  # changes format. Each value in the hash
  # needs to be in an array, but for any
  # new record, sometimes an attribute does not
  # have previous value. So we need to handle that.
  # Also, the
  def normalize_changes(changes)
    to_return = {}

    # Standardize changes to array
    changes.each_pair do |key, value|
      change = if value.is_a?(Array)
        value
      else
        [nil, value.to_s]
      end

      change = change.map { |x| x.blank? ? '(blank)' : x }

      # Ignore values that do not really change
      to_return[key] = change if change.first != change.last
    end

    to_return
  end
end
