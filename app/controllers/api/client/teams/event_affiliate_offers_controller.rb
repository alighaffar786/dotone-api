class Api::Client::Teams::EventAffiliateOffersController < Api::Client::Teams::BaseController
  load_resource class: 'AffiliateOffer'

  def index
    authorize! :read_event, AffiliateOffer
    @event_affiliate_offers = paginate(query_index)
    respond_with_pagination @event_affiliate_offers, each_serializer: Teams::EventAffiliateOfferSerializer
  end

  def create
    authorize! :create_event, AffiliateOffer
    if @event_affiliate_offer.save
      respond_with @event_affiliate_offer, serializer: Teams::EventAffiliateOfferSerializer
    else
      respond_with @event_affiliate_offer, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update_event, @event_affiliate_offer
    if @event_affiliate_offer.update(event_affiliate_offer_params)
      respond_with @event_affiliate_offer, serializer: Teams::EventAffiliateOfferSerializer
    else
      respond_with @event_affiliate_offer, status: :unprocessable_entity
    end
  end

  def bulk_update
    authorize! :update_event, AffiliateOffer
    start_bulk_update_job(
      AffiliateOffers::BulkUpdateJob,
      event_affiliate_offer_params,
    )
    head :ok
  end

  def download
    authorize! :download_event, AffiliateOffer
    @download = build_download(query_index, [], type: :event)
    @download.name = 'Event Campaigns'
    authorize! :create, @download
    authorize! :download, AffiliateOffer

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = EventAffiliateOfferCollection.new(@event_affiliate_offers, params).collect
    collection = collection.preload(:affiliate, :aff_hash, :site_info, event_offer: [:default_offer_variant, :name_translations, default_conversion_step: :true_currency])
    collection = collection.preload(affiliate: [:affiliate_application, :group_tags]) if can?(:read, Affiliate)
    collection
  end

  def event_affiliate_offer_params
    params
      .require(:event_affiliate_offer)
      .permit(
        :event_published_url, :approval_status, :status_summary, :status_reason, :requested_affiliate_pay, :affiliate_id, :offer_id
      )
  end
end
