module Relations::HasCategoryGroups
  extend ActiveSupport::Concern
  include Scopeable

  included do
    scope_by_category_group
  end

  module ClassMethods
    def has_many_category_groups(**options)
      has_many :category_groups, **options
    end
  end
end
