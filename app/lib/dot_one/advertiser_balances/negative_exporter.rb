require 'csv'

class DotOne::AdvertiserBalances::NegativeExporter < DotOne::Exporters::Base
  attr_reader :networks

  def initialize(**options)
    @name = 'Advertisers'
    @networks = query_networks(options[:balance_type]).to_a
  end

  def should_export?
    networks.present?
  end

  private

  def header
    @header ||= [
      t(:network_id),
      t(:network_name),
      t(:available_balance),
      t(:total_pending_payouts),
      t(:total_published_payouts),
      t(:remaining_balance),
    ]
  end

  def body
    @body ||= networks.map do |network|
      [
        network.id,
        network.id_with_name,
        as_currency(network.current_balance),
        as_currency(network.pending_payout),
        as_currency(network.published_payout),
        as_currency(network.remaining_balance),
      ]
    end
  end

  def footer
    @footer ||= [
      nil,
      t(:total),
      as_currency(networks.map(&:current_balance).sum),
      as_currency(networks.map(&:pending_payout).sum),
      as_currency(networks.map(&:published_payout).sum),
      as_currency(networks.map(&:remaining_balance).sum),
    ]
  end

  def query_networks(balance_type)
    case balance_type
    when :positive
      Network.with_positive_remaining_balance
    when :negative
      Network.with_negative_remaining_balance
    else
      Network.with_part_of_balance
    end
  end

  def t(key, **options)
    super("reports.models.stat.network_balance_exporter.#{key}", **{ locale: Language.current_locale }.merge(options)).strip
  end
end
