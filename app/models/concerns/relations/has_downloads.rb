module Relations::HasDownloads
  extend ActiveSupport::Concern

  included do
    has_many :downloads, as: :owner, inverse_of: :owner, dependent: :destroy
  end
end
