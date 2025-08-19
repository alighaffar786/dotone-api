class DotOne::Reports::AffiliateUsers::ClaimableAffiliateBalance
  attr_reader :ability

  def initialize(user = nil)
    @ability = user.is_a?(Ability) ? user : Ability.new(user) if user
  end

  def generate
    [:inactive_affiliates, :inactive_capture_affiliates].map do |name|
      generate_excel(name) do |workbook|
        workbook.add_worksheet(name: name.to_s) do |worksheet|
          header = Affiliate.generate_download_headers(Affiliate.download_inactive_columns).to_h.values
          worksheet.add_row(header)

          send("query_#{name}").find_each do |affiliate|
            row = generate_row(affiliate)
            worksheet.add_row(row)
          end
        end
      end
    end
  end

  def query_affiliates
    ability ? Affiliate.accessible_by(ability) : Affiliate
  end

  def query_inactive_affiliates
    query_affiliates
      .where.not(current_balance: nil)
      .where('current_balance > 0 AND last_request_at <= DATE_SUB(NOW(), INTERVAL 540 DAY)')
  end

  def query_inactive_capture_affiliates
    query_affiliates
      .joins(
        <<-SQL.squish
          LEFT OUTER JOIN (
            SELECT affiliate_id, COUNT(*) AS captured_count
            FROM affiliate_stat_captured_ats
            WHERE captured_at >= DATE_SUB(NOW(), INTERVAL 540 DAY)
            GROUP BY affiliate_id
          ) AS captured_data
          ON captured_data.affiliate_id = affiliates.id
        SQL
      )
      .where.not(current_balance: nil)
      .where('current_balance > 0 AND captured_data.captured_count IS NULL')
  end

  private

  def generate_excel(name)
    excel = Axlsx::Package.new
    yield(excel.workbook)

    file_name = "#{name}_#{localize_date_format(Date.today)}.xlsx"
    output_path = Rails.root.join('tmp', file_name).to_s

    excel.serialize(output_path)
    output_path
  end

  def generate_row(affiliate)
    [
      affiliate.id,
      affiliate.current_balance,
      localize_date_format(affiliate.last_request_at_local),
    ]
  end

  def localize_date_format(date)
    date && I18n.l(date, format: :global)
  end
end
