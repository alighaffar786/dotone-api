module Relations::HasUploads
  extend ActiveSupport::Concern

  included do
    has_many :uploads, as: :owner, inverse_of: :owner, dependent: :destroy
  end
end
