module AppRoleable
  extend ActiveSupport::Concern
  include ConstantProcessor

  ROLES = ['affiliate', 'network'].freeze

  included do
    validates :role, inclusion: { in: ROLES }

    define_constant_methods(ROLES, :role)
  end
end
