#source: http://railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/
module ClassLevelInheritAttributes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def inherit_attributes(*args)
      @inherit_attributes ||= [:inherit_attributes]
      @inherit_attributes += args
      args.each do |arg|
        class_eval %(
          class << self; attr_accessor :#{arg} end
        )
      end
      @inherit_attributes
    end

    def inherited(subclass)
      @inherit_attributes.each do |inherit_attribute|
        instance_var = "@#{inherit_attribute}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
      end
    end
  end
end
