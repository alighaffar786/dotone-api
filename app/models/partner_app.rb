class PartnerApp < DatabaseRecords::PrimaryRecord
  include NameHelper
  include Relations::HasApiKeys
  include Relations::HasChannels

  has_many :access_tokens, inverse_of: :partner_app, dependent: :nullify
  has_many :networks, inverse_of: :partner_app, dependent: :nullify

  scope :is_public, -> { where(visibility: visibility_public) }

  def self.visibility_public
    'Public'
  end
end
