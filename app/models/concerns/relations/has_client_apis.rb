module Relations::HasClientApis
  extend ActiveSupport::Concern

  included do
    has_many :client_apis, as: :owner, inverse_of: :owner, dependent: :destroy
  end
end
