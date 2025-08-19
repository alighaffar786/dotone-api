module Userable
  extend ActiveSupport::Concern

  included do
    belongs_to :user, inverse_of: self.name.tableize

    scope :with_users, -> (*args) {
      if args.present? && args[0].is_a?(User)
        where(user_id: [args[0].id] + args[0].all_colleague_ids)
      end
    }
  end
end
