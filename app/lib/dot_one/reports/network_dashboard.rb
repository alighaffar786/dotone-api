# frozen_string_literal: true

class DotOne::Reports::NetworkDashboard
  attr_accessor :network, :params, :time_zone, :currency_code

  REPORT_TYPES = [
    :exposure, :account_overview, :performance_stat, :total_order, :visitor, :commission_balance, :publisher
  ]

  REPORT_TYPES.each do |report_type|
    define_method "generate_#{report_type}" do
      report_klass = "DotOne::Reports::Dashboard::#{report_type.to_s.classify}".constantize
      report = report_klass.new(
        network: network,
        time_zone: time_zone,
        currency_code: currency_code,
        params: params,
      )
      report.generate
    end
  end

  def initialize(args)
    @network = args[:network]
    @params = args[:params]
    @time_zone = args[:time_zone]
    @currency_code = args[:currency_code]
  end

  def self.report_types
    REPORT_TYPES
  end

  def generate
    result = {}

    AdvertiserMetrics.report_types.each do |report_type|
      result[report_type] = send("generate_#{report_type}")
    end

    result
  end
end
