module AffiliateLoggable
  extend ActiveSupport::Concern

  included do
    has_many :affiliate_logs, as: :owner, inverse_of: :owner, dependent: :destroy
    has_many :network_logs, -> { where(agent_type: 'Network') }, class_name: 'AffiliateLog', as: :owner, inverse_of: :owner
    has_many :admin_logs, -> { where(agent_type: [nil, 'AffiliateUser']) }, class_name: 'AffiliateLog', as: :owner, inverse_of: :owner
  end

  def latest_logs
    @latest_logs ||= affiliate_logs.limit(3).to_a
  end

  def notes
    @notes ||= latest_logs.map do |log|
      "#{log.created_at_local.to_date}: #{log.notes}"
    end
      .join(' ')
  end
end
