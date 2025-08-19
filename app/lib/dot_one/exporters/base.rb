require 'csv'
require 'axlsx'

class DotOne::Exporters::Base
  include DotOne::I18n

  attr_accessor :name, :body

  def export(**options)
    return unless should_export?

    case options[:format]
    when :csv
      export_csv
    when :xlsx
      export_xlsx
    else
      {
        output_csv: export_csv,
        output_xlsx: export_xlsx,
      }
    end
  end

  def should_export?
    true
  end

  def export_csv
    output = generate_temp_filename('csv')
    File.write(output, generate_csv)
    output
  end

  def export_xlsx
    output = generate_temp_filename('xlsx')
    generate_xlsx.serialize(output)
    output
  end

  def generate_csv
    ::CSV.generate do |csv|
      csv << header if header.present?
      body.each { |row| csv << row }
      csv << footer if footer.present?
    end
  end

  def generate_xlsx
    workbook = xlsx.workbook
    styles = workbook.styles
    h_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER, bg_color: 'EEEEEE', b: true)
    d_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER)

    workbook.add_worksheet(name: name) do |sheet|
      sheet.add_row(header, style: h_style) if header.present?
      body.each { |row| sheet.add_row(row, style: d_style) }
      sheet.add_row(footer, style: h_style) if footer.present?
    end

    xlsx
  end

  def header
    []
  end

  def footer
    []
  end

  def body
    @body || []
  end

  protected

  def generate_temp_filename(ext)
    DotOne::Utils::File.generate_temp_filename(ext)
  end

  def as_currency(value, currency_code = nil)
    "#{currency_code || Currency.platform_code} %0.2f" % value.to_f
  end

  def xlsx
    @xlsx ||= build_xlsx
  end

  def build_xlsx
    package = Axlsx::Package.new
    package.use_shared_strings = true
    package
  end
end
