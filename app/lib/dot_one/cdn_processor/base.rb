# frozen_string_literal: true

module DotOne::CdnProcessor::Base
  class Record
    COLUMNS = [
      :date,            # date
      :time,            # time
      :location,        # x-edge-location
      :bytes,           # sc-bytes
      :ip_address,      # c-ip
      :http_method,     # cs-method
      :host,            # cs(Host)
      :uri_stem,        # cs-uri-stem
      :http_status,     # sc-status
      :http_referer,    # cs(Referer)
      :http_user_agent, # cs(User-Agent)
      :uri_query,       # cs-uri-query
      :http_cookie,     # cs(Cookie)
      :result_type,     # x-edge-result-type
      :request_id,      # x-edge-request-id
      :http_host,       # x-host-header
      :http_protocol,   # cs-protocol
      :http_bytes,      # cs-bytes
      :time_taken,      # time-taken
      :forwarded_for,   # x-forwarded-for
      :ssl_protocol,    # ssl-protocol
      :ssl_cipher,      # ssl-cipher
      :response_type,   # x-edge-response-result-type
      :http_version,    # cs-protocol-version
    ].freeze

    QUERIES = [
      :ad_slot_id, :affiliate_id, :affiliate_offer_id, :image_creative_id,
      :network_id, :offer_id, :offer_variant_id, :track, :wl,
      :text_creative_id
    ].freeze

    attr_accessor :row

    def initialize(row = [])
      @row = row
    end

    COLUMNS.each_with_index do |column, index|
      define_method column do
        row[index].try(:[], 0, 999)
      end
    end

    QUERIES.each do |query|
      define_method query do
        queries[query]
      end
    end

    def recordable?
      raise NotImplementedError
    end

    def wl_valid?
      wl.to_s == DotOne::Setup.wl_id.to_s
    end

    def queries
      CGI.parse(uri_query).transform_values do |values|
        values.try(:[], 0) || true
      end.to_h.with_indifferent_access
    rescue StandardError
      {}
    end

    def http_referer_host_name
      return if http_referer.blank?

      DotOne::Utils::Url.host_name(http_referer)
    end

    def recorded_at
      Time.parse("#{date} #{time}")
    end

    def ip_v4_address
      row[4].length > 20 ? nil : ip_address
    end
  end

  class Processor
    attr_accessor :records

    def initialize
      @records = {}
    end

    def add_row(row)
      raise NotImplementedError
    end

    def save(batch, logger)
      raise NotImplementedError
    end

    def rollback(batch, logger)
      raise NotImplementedError
    end
  end
end
