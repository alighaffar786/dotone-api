# frozen_string_literal: true

class Notifiers::NegativeBalancesJob < NotificationJob
  def perform
    exporter = DotOne::AdvertiserBalances::NegativeExporter.new(balance_type: :negative)
    result = exporter.export

    return unless result

    AffiliateUserMailer
      .notify_negative_balance_advertisers(result)
      .deliver_later
  end
end
