class Channel < DatabaseRecords::PrimaryRecord
  include LocalTimeZone
  include ModelCacheable
  include NameHelper
  include Owned
  include Userable
  include Relations::AffiliateStatAssociated

  belongs_to_owner touch: true

  has_many_affiliate_stats
  has_many :affiliates, inverse_of: :channel, dependent: :nullify
  has_many :campaigns, inverse_of: :channel, dependent: :destroy
  has_many :networks, inverse_of: :channel, dependent: :nullify

  set_local_time_attributes :created_at

  scope :recent, -> { order(created_at: :desc) }

  scope :like, -> (*args) {
    where('id LIKE :q OR name LIKE :q', q: "%#{args[0]}%") if args[0].present?
  }

  def self.populate_channel_for_new_media_buyer(user_id)
    ['Facebook', 'Bing', 'Google Adwords'].each do |channel_name|
      channel = Channel.create(name: channel_name, user_id: user_id)
    end
  end
end
