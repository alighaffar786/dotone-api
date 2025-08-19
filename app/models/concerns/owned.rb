module Owned
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, polymorphic: true, inverse_of: name.tableize

    validates :owner, presence: true

    scope :owned_by, -> (owner_type, *owner_ids) {
      result = where(owner_type: owner_type)
      result = result.where(owner_id: owner_ids) if owner_ids[0].present?
      result
    }
  end

  module ClassMethods
    def belongs_to_owner(**options)
      belongs_to :owner, **{ polymorphic: true, inverse_of: name.tableize }.merge(options)
    end
  end

  def cached_owner
    owner_klass = owner_type.constantize
    return owner_klass.cached_find(owner_id) if owner_klass.respond_to?(:cached_find)
    owner
  end
end
