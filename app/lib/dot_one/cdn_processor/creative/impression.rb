# frozen_string_literal: true

module DotOne::CdnProcessor::Creative::Impression
  class Record < DotOne::CdnProcessor::Base::Record
    attr_accessor :id_prefix

    ##
    # Returns 1 to mark it as impression
    def impression
      1
    end

    def id
      [@id_prefix, DotOne::Utils.generate_token].join('.')
    end

    def recordable?
      wl_valid? && (text_creative_id.present? || image_creative_id.present?)
    end
  end

  class Processor < DotOne::CdnProcessor::Base::Processor
    def initialize
      super
      @records = []
    end

    def add_row(row, source_file)
      return false if row.blank?

      record = Record.new.tap do |c|
        c.row = row
        c.id_prefix = source_file
      end

      return false unless record.recordable?

      records << record
      true
    end

    def rollback(batch)
      DotOne::Services::S3RedshiftConnector.rollback_impressions(batch)
    end

    def save(_batch)
      # Record impression to Redshift directly
      DotOne::Services::S3RedshiftConnector.s3_to_redshift(records)
    end
  end
end
