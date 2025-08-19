class Api::Client::Affiliates::AdSlotsController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource except: :recent

  def index
    @ad_slots = paginate(query_index)
    respond_with_pagination @ad_slots
  end

  def recent
    authorize! :read, AdSlot
    @ad_slots = query_index.limit(10)
    respond_with @ad_slots
  end

  def create
    if @ad_slot.save
      respond_with @ad_slot
    else
      respond_with @ad_slot, status: :unprocessable_entity
    end
  end

  def update
    if @ad_slot.update(ad_slot_params)
      respond_with @ad_slot
    else
      respond_with @ad_slot, status: :unprocessable_entity
    end
  end

  def destroy
    @ad_slot.mark_as_archived
    head :ok
  end

  private

  def query_index
    AdSlotCollection.new(current_ability, params)
      .collect
      .preload(
        :category_groups, offers: :name_translations,
        text_creative: [:image, offer: [:aff_hash, :name_translations, :offer_name_translations]]
      )
  end

  def ad_slot_params
    params
      .require(:ad_slot)
      .permit(
        :name, :text_creative_id, :dimensions, :offer_ids, :category_group_ids,
        offer_ids: [], category_group_ids: []
      )
  end
end
