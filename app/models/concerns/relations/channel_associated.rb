module Relations::ChannelAssociated
  extend ActiveSupport::Concern
  include Scopeable

  included do
    belongs_to :channel, inverse_of: self.name.tableize

    scope_by_channel
  end

  def cached_channel
    Channel.cached_find(channel_id)
  end
end
