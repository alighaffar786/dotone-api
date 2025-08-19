module DotOne::DownloadNotes
  class Default
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def date_notes
      return if params[:start_date].blank? && params[:end_date].blank?

      "Date Range: #{to_string([params[:start_date], params[:end_date]], ' to ')}"
    end

    def network_offer_notes
      return if params[:offer_ids].blank?

      "Offers: #{to_string(NetworkOffer.where(id: params[:offer_ids]))}"
    end

    def event_offer_notes
      return if params[:event_offer_ids].blank?

      "Events: #{to_string(EventOffer.where(id: params[:event_offer_ids]))}"
    end

    def network_notes
      return if params[:network_ids].blank?

      "Advertisers: #{to_string(Network.where(id: params[:network_ids]))}"
    end

    def affiliate_notes
      return if params[:affiliate_ids].blank?

      "Affiliates: #{to_string(Affiliate.where(id: params[:affiliate_ids]))}"
    end

    def status_notes
      return if params[:statuses].blank?

      "Status: #{to_string(params[:statuses])}"
    end

    def notes
      [
        date_notes,
        network_offer_notes,
        network_notes,
        event_offer_notes,
        affiliate_notes,
        status_notes,
      ]
    end

    def generate
      notes.reject(&:blank?).join('<br>')
    end

    protected

    def to_string(items, seperator = ', ')
      if items.is_a?(ActiveRecord::Relation)
        items.map(&:id_with_name).join(seperator)
      else
        [items].flatten.reject(&:blank?).join(seperator)
      end
    end
  end
end
