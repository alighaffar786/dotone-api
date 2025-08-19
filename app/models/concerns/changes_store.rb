module ChangesStore
  extend ActiveSupport::Concern

  included do
    # should be used in callback commit
    attr_accessor :patched_previous_changes

    after_initialize :reset_patched_previous_changes
    before_save :reset_patched_previous_changes
    after_save :store_changes
    after_touch :store_changes
  end

  def reset_patched_previous_changes
    self.patched_previous_changes = {}
  end

  def store_changes
    return unless previous_changes.present?

    previous_changes.each do |attribute, values|
      if prev_value = values.first
        self.patched_previous_changes[attribute] = prev_value
      end
    end

    self.patched_previous_changes = patched_previous_changes.with_indifferent_access
  end

  def touch(*, **)
    reset_patched_previous_changes

    super
  end
end
