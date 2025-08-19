require 'rubygems'
require 'zip'
require 'fileutils'
require 'csv'
require 'axlsx'

class Download < DatabaseRecords::PrimaryRecord
  include ActionView::Helpers::NumberHelper
  include ConstantProcessor
  include LocalTimeZone
  include Owned
  include PurgeableFile

  STATUSES = ['In Progress', 'Ready', 'Error']

  attr_accessor :locale, :currency_code, :time_zone, :formatters, :download_format

  before_create :set_defaults

  mount_uploader :file, FileUploader

  define_constant_methods(STATUSES, :status)
  set_purgeable_file_attributes :cdn_url
  # TODO: Deprecate serialize
  # TODO: Change database column format to json
  serialize :headers
  serialize :extra_info, Hash

  set_local_time_attributes :created_at

  def limit
    @limit ||= 1000
  end

  def header_array?
    headers[0].is_a?(Array)
  end

  def report_headers
    @report_headers ||= if header_array?
      headers.map do |x|
        header = x[1]

        if model_forex_attributes.include?(x[0].to_sym)
          header << " (#{currency_code || Currency.current_code})"
        end

        header
      end
    else
      headers
    end
  end

  def database_headers
    @database_headers ||= if header_array?
      headers.map { |x| x[0] }
    else
      headers
    end
  end

  def model
    file_type.constantize
  end

  def model_translatable_attributes
    unless model.respond_to?(:dynamic_translatable_attributes) || model.respond_to?(:static_translatable_attributes)
      return []
    end

    model.try(:dynamic_translatable_attributes).to_a + model.try(:static_translatable_attributes).to_a
  end

  def model_local_time_attributes
    return [] unless model.respond_to?(:local_time_attributes)

    model.local_time_attributes
  end

  def model_forex_attributes
    return [] unless model.respond_to?(:forexable_attributes)

    model.forexable_attributes
  end

  def model_maskable_attributes
    return [] unless model.respond_to?(:maskable_address_attributes)

    model.maskable_address_attributes
  end

  def query_records(offset = 0)
    if model == Stat
      model.find_by_sql("#{exec_sql} LIMIT #{limit} OFFSET #{offset}")
    else
      model.find_by_sql("#{exec_sql} LIMIT #{offset}, #{limit}")
    end
  end

  def generate_csv(options = {})
    generate_tmp_file('csv') do |output|
      CSV.open(output, 'w', headers: true, write_headers: true, force_quotes: true) do |csv|
        # To make it Excel-friendly
        csv.to_io.write "\uFEFF" # use CSV#to_io to write BOM directly
        csv << report_headers
        generate_rows(options) do |row|
          csv << row.map do |cell|
            if cell.is_a?(String) && cell.match(/\A\d+\z/) && cell.length > 15
              # handle long numbers when opening CSV in Excel, adding a space after long number
              "#{cell}\u00A0"
            else
              cell
            end
          end
        end
      end

      File.open(output, 'r') do |file|
        self.file = file
        self.status = Download.status_ready
        save
      end
    end
  end

  def generate_xlsx(options = {})
    generate_tmp_file('xlsx') do |output|
      package = Axlsx::Package.new
      workbook = package.workbook
      styles = workbook.styles
      h_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER, b: true)
      b_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER)

      workbook.add_worksheet do |sheet|
        header = report_headers
        types = header.map { :string }
        sheet.add_row(header, style: h_style, types: types)
        generate_rows(options) do |row|
          sheet.add_row(row, style: b_style, types: types)
        end
      end

      package.serialize(output)

      File.open(output, 'r') do |file|
        self.file = file
        self.status = Download.status_ready
        save
      end
    end
  end

  def generate_xml(options = {})
    generate_tmp_file('xml') do |output|
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.root do
          generate_rows(options) do |row|
            xml.entry do
              report_headers.each_with_index do |header, index|
                name = header.strip.gsub(/\n+/, '')
                xml.column(row[index], name: name)
              end
            end
          end
        end
      end

      File.open(output, 'w+') do |file|
        file.write(builder.to_xml)

        self.file = file
        self.status = Download.status_ready
        save
      end
    end
  end

  def generate(options = {})
    download_format ||= options[:format] || :csv
    send("generate_#{download_format}", options)
  end

  def generate_rows(options = {})
    set_options(options)
    offset = 0

    loop do
      records = query_records(offset)
      break if records.empty?

      records.each do |record|
        record.download_meta = options.merge(owner: owner) if record.respond_to?(:download_meta)
        row = build_row(record)
        yield(row)
      end

      break if records.size < limit
      offset += limit
      break if offset > 10_000
    end
  end

  def requeue_generate_csv
    DownloadJob.perform_later(id)
  end

  def queue_generate(**options)
    return unless in_progress?

    DownloadJob.perform_later(id, { format: download_format }.merge(**options))
  end

  def queue_generate_csv(**options)
    queue_generate(**options.merge(format: :csv))
  end

  def queue_generate_xlsx(**options)
    queue_generate(**options.merge(format: :xlsx))
  end

  def queue_generate_xml(**options)
    queue_generate(**options.merge(format: :xml))
  end

  def get_value(record, attribute)
    return record.send("#{attribute}_local", time_zone) if model_local_time_attributes.include?(attribute.to_sym)
    return record.send("masked_#{attribute}") if model_maskable_attributes.include?(attribute.to_sym)
    return record.send("t_#{attribute}", locale) if model_translatable_attributes.include?(attribute.to_sym)
    return record.send("forex_#{attribute}", currency_code) if model_forex_attributes.include?(attribute.to_sym)

    record.send(attribute)
  end

  def owner_ability
    @owner_ability ||= Ability.new(owner)
  end

  def build_row(record)
    database_headers.map do |attribute|
      column = if formatter = formatters && formatters[attribute.to_sym]
        args = [record, owner_ability]
        formatter.call(*args.take(formatter.arity))
      else
        value = get_value(record, attribute)

        if value.instance_of?(Time)
          # Standardize the format
          value.to_s(:db)
        elsif value.is_a?(Array)
          value.join(', ')
        else
          value
        end
      end

      column
    end
  end

  def self.clean_up(number_days)
    Download.where('created_at < ?', number_days.days.ago).each(&:destroy)
  end

  def generate_tmp_file(ext)
    output = "#{Rails.root}/tmp/#{DotOne::Utils.generate_token}.#{ext}"

    yield output

    File.delete(output) rescue nil
  end

  # TODO: exception rescued because deleting Download is giving error while deleting it from AWS
  def destroy
    super
  rescue Excon::Error::BadRequest
    true
  end

  private

  def set_defaults
    self.status ||= Download.status_in_progress
    self.name = "#{name} (#{(download_format || :csv).upcase})"
  end

  def set_options(options = {})
    self.locale = options[:locale] || Language.current_locale
    self.currency_code = options[:currency_code] || Currency.current_code
    self.time_zone = options[:time_zone] || TimeZone.current
    self.formatters = model.try(options[:formatters] || :download_formatters) || {}
  end
end
