module DotOne::Api::V2Helper
  include ActionView::Helpers::NumberHelper

  def to_commission_range(commissions)
    cps = commissions.select { |commission| ConversionStep.is_share_rate?(:affiliate, commission[:conv_type]) }
    cpl = commissions.select { |commission| ConversionStep.is_flat_rate?(:affiliate, commission[:conv_type]) }

    cps_string = nil
    if cps.present?
      cps_values = [cps.first[:value]]
      cps_values.push(cps.last[:value]) unless cps.first == cps.last

      cps_string = cps_values.map { |value| to_currency(value) }.join(' - ')
    end

    cpl_string = nil
    if cpl.present?
      cpl_values = [cpl.first[:value]]
      cpl_values.push(cpl.last[:value]) unless cpl.first == cpl.last

      cpl_string = cpl_values.map { |value| to_percentage(value) }.join(' - ')
    end

    [cpl_string, cps_string].compact.join(', ')
  end

  def to_currency(value)
    number_to_percentage(value, precision: 2)
  end

  def to_percentage(value)
    format = I18n.t("number.currency.formats.plain_format")

    number_to_currency(value, unit: currency_code, format: format)
  end
end
