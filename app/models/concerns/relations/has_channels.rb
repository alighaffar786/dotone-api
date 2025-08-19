module Relations::HasChannels
  extend ActiveSupport::Concern

  included do
    has_many :channels, as: :owner, inverse_of: :owner, dependent: :nullify
  end
end
