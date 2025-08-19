module DotOne::DownloadNotes
  class AdvertiserBalanceNote < Default
    def record_type_notes
      return if params[:record_types].blank?
      "Record Type: #{to_string(params[:record_types].map { |r|  translate(r, 'record_type') })}"
    end

    def translate(value, attr)
      DotOne::I18n.predefined_t("advertiser_balance.#{attr}.#{value}")
    end

    def notes
      super + [record_type_notes]
    end
  end
end
