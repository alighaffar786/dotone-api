module Bulkable
  extend ActiveSupport::Concern

  module ClassMethods
    def bulk_attributes(*args)
      class_eval do
        class << self
          attr_accessor :bulk_attributes
        end
        @bulk_attributes = args
      end
    end

    def bulk_names
      @bulk_attributes.map { |x| x.to_s }
    end

    def column_headers
      %(#{bulk_names})
    end

    # data is a comma-separated string
    def bulk_table(data, setup = {})
      require 'csv'
      table = []
      if setup.blank?
        table = CSV.parse(data)
      else
        date_pos  = setup[:date_column_position].to_i - 1
        ad_pos    = setup[:ad_column_position].to_i - 1
        cost_pos  = setup[:cost_column_position].to_i - 1
        head_idx  = setup[:header_row_number].to_i
        foot_idx  = table.length - setup[:footer_row_number].to_i - 1
        CSV.parse(data) do |row|
          table << [row[date_pos], row[ad_pos], row[cost_pos]]
        end
        table = table[head_idx..foot_idx]
      end
      table
    end

    # data is a hash containing the data from client bulk upload table
    # example:
    # data = {
    #   1 => ["data 11", "data 12", 13, "another data 14"],
    #   2 => ["data 21", "data 22", 23, "another data 24"],
    #   3 => ["data 31", "data 32"]
    # }
    def bulk_raw(data)
      return if data.blank?

      rows = []
      data.keys.each do |k|
        d = data[k].map { |x| x.include?('"') ? "\"#{x.gsub('"', '""')}\"" : "\"#{x}\"" }
        rows << d.join(',')
      rescue StandardError
        next
      end
      rows.join("\r\n")
    end

    # data is a hash containing the data from client bulk upload table
    # example:
    # data = {
    #   1 => ["data 11", "data 12", 13, "another data 14"],
    #   2 => ["data 21", "data 22", 23, "another data 24"],
    #   3 => ["data 31", "data 32"]
    # }
    # Callbacks:
    # before_save(entity) - callback before the entity is saved
    # after_save(entity) - callback after the entity is saved
    def bulk_create(data, procs = {})
      result = {}
      result[:total] = 0
      result[:total_ok] = 0
      result[:total_fail] = 0
      result[:fail_records] = {}

      data.each_pair do |key, value|
        params = {}
        @bulk_attributes.each_with_index do |p, idx|
          params[p] = value[idx].strip
        end
        entity = new(params)
        procs[:before_save].call(entity) if procs[:before_save].present?
        result[:total] += 1
        if entity.save
          result[:total_ok] += 1
          procs[:after_save].call(entity) if procs[:after_save].present?
        else
          result[:total_fail] += 1

          # overwrite error message column when exist
          if value.length > @bulk_attributes.length
            value[value.length - 1] = entity.errors.full_messages.join('. ')
            result[:fail_records][key] = value
          else
            result[:fail_records][key] = (value + [entity.errors.full_messages.join('. ')])
          end
        end
      rescue StandardError
        next
      end
      result
    end
  end
end
