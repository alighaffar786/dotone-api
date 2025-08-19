require 'csv'
require 'open-uri'
require 'net/https'

class Upload < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include LocalTimeZone
  include Owned
  include PurgeableFile

  STATUSES = ['In Progress', 'Ready', 'Error', 'Warning', 'Pending']

  before_validation :set_defaults

  mount_uploader :file, FileUploader

  define_constant_methods STATUSES, :status
  set_local_time_attributes :created_at
  set_purgeable_file_attributes :cdn_url

  scope :like, -> (*args) {
    where('id LIKE :q OR descriptions LIKE :q', q: "%#{args[0]}%") if args[0].present?
  }

  def uploaded_by
    super.presence || owner&.name_with_role
  end

  def cdn_url
    super.presence || file.url
  end

  def file_type
    return if cdn_url.blank?

    File.extname(cdn_url).to_s.gsub('.', '')
  end

  ##
  # Method to create payments as specified
  # by the Proposal CSV
  def create_payments_from_csv
    AffiliatePayment.upload_proposal(self)
  end

  # source: http://stackoverflow.com/questions/15386404/open-csv-file-as-csvtable-form-url
  def to_csv_table
    # Get StringIO from URL using open-uri
    stringio = open(file.to_s, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)

    # Create a new CSV object from StringIO
    csvobj = CSV.new(stringio)

    # Create an array of rows from CSV object
    array_of_rows = csvobj.read

    # Separate header from values
    header = array_of_rows[0]
    aux = array_of_rows.length - 1
    values = array_of_rows[1..aux]

    # Create array of CSV::Row objects
    values_row = values.map { |row| CSV::Row.new(header, row) }

    # Create a CSV::Table object from array of CSV::Row
    CSV::Table.new(values_row)
  end

  def csv_rows(**options)
    return [] if cdn_url.blank?
    encodings = options.delete(:encodings) || ['UTF-8', 'Big5']

    new_options = {
      headers: true,
      skip_blanks: true,
      header_converters: :symbol,
    }.merge(options)

    content = URI.open(cdn_url, encoding: encodings.shift).read
    CSV.parse(content, **new_options).map do |row|
      row.to_h.with_indifferent_access.transform_values { |value| value&.squish }
    end
  rescue CSV::MalformedCSVError => e
    if encodings.present?
      csv_rows(**options.merge(encodings: encodings))
    else
      raise e
    end
  end

  def upload_error_details
    return if error_details.blank?

    path = Rails.root.join('tmp', "upload_#{id}.txt")
    uploader = UploadErrorUploader.new(self)

    File.open(path, 'w') do |file|
      file.write(error_details)

      uploader.store!(file)
    end
    File.delete(path)

    self.error_details = uploader.url
  end

  private

  def set_defaults
    self.status ||= Upload.status_pending
    self.uploaded_by ||= owner.try(:name_with_role) if owner.present?
  end
end
