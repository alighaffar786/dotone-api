class BotStat < DatabaseRecords::PrimaryRecord
  include AffiliateStatHelpers::Common

  scope :like, -> (*args) {
    where('id LIKE :q', q: "%#{args[0]}%") if args[0].present?
  }

  def country
    @country ||= Country.cached_find_by(name: ip_country)
  end

  def self.approvals_considered_pending(user_role = nil)
    if user_role == :network
      [
        approval_pending,
        approval_invalid,
      ]
    else
      [
        approval_pending,
      ]
    end
  end

  def to_click
    return if AffiliateStat.exists?(id: id)

    AffiliateStat.create!(attributes)
  end
end
