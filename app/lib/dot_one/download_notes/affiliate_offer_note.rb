module DotOne::DownloadNotes
  class AffiliateOfferNote < Default
    def event_status_notes
      return if params[:event_statuses].blank?

      "Event Status: #{to_string(params[:event_statuses])}"
    end

    def approval_status_notes
      return if params[:approval_statuses].blank?

      "Campaign Status: #{to_string(params[:approval_statuses])}"
    end

    def notes
      super + [event_status_notes, approval_status_notes]
    end
  end
end
