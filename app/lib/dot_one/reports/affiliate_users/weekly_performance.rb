module DotOne::Reports::AffiliateUsers
  class WeeklyPerformance
    def initialize(date)
      @date = date
    end

    def build_report
      @affiliate_weekly_report = AffiliatePerformance.build_report
      @advertiser_weekly_report = AdvertiserPerformance.build_report
      @offer_weekly_report = OfferPerformance.build_report
      @revenue_weekly_report = RevenuePerformance.build_report

      I18n.with_locale('en-US') do
        generate_xlsx
      end
    end

    def generate_xlsx
      excel_package = Axlsx::Package.new
      excel_package.workbook.add_worksheet(name: 'weekly_performance_report.xlsx') do |worksheet|
        add_headers(worksheet)

        4.times do |index|
          worksheet.add_row report_row(index)
        end
      end
      output = "#{Rails.root}/tmp/#{SecureRandom.uuid}.xlsx"
      excel_package.serialize(output)
      output
    end

    def report_row(index)
      (start_date, end_date) = @affiliate_weekly_report[index][:week]

      [
        "#{start_date.strftime('%m/%d')}-#{end_date.strftime('%m/%d')}",
        # Sorting the keys matters
        *@affiliate_weekly_report[index][:week_data].values,
        *@advertiser_weekly_report[index][:week_data].values,
        *@offer_weekly_report[index][:week_data].values,
        *@revenue_weekly_report[index][:week_data].values,
      ]
    end

    def headers
      [
        translate('week'),
        translate('publishers').values,
        translate('advertisers').values,
        translate('offers').values,
        translate('revenues').values,
      ].flatten
    end

    def top_headers
      week_col = 1
      total_column = headers.size + week_col
      [*0...total_column].map do |index|
        case index
        when 1
          translate('top_headers.publishers')
        when 13
          translate('top_headers.advertisers')
        when 23
          translate('top_headers.offers')
        when 35
          translate('top_headers.revenues')
        end
      end
    end

    def add_headers(worksheet)
      worksheet.add_row top_headers
      worksheet.merge_cells 'B1:M1'
      worksheet.merge_cells 'N1:W1'
      worksheet.merge_cells 'X1:AI1'
      worksheet.merge_cells 'AJ1:AP1'

      worksheet.add_row headers

      worksheet.rows[0].cells[1].style = top_header_style(worksheet, bg_color: '51AD4C')
      worksheet.rows[0].cells[13].style = top_header_style(worksheet, bg_color: 'EEACDF')
      worksheet.rows[0].cells[23].style = top_header_style(worksheet, bg_color: 'B0CAE2')
      worksheet.rows[0].cells[35].style = top_header_style(worksheet, bg_color: 'FFF3CC')
    end

    def top_header_style(worksheet, styles = {})
      worksheet.styles&.add_style(
        {
          bg_color: '51AD4C',
          fg_color: '000000',
          b: true,
          alignment: {
            horizontal: :center,
            vertical: :center,
          },
        }.merge(styles),
      )
    end

    def translate(path)
      I18n.t(path, scope: [:reports, :weekly_performance])
    end
  end
end
