module DotOne::DownloadNotes
  class AffiliateStatNote < Default
    def approval_notes
      return if params[:approvals].blank?

      "Transaction Status: #{to_string(params[:approvals])}"
    end

    def notes
      super + [approval_notes]
    end
  end
end
