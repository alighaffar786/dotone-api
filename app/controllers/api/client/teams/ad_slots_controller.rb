class Api::Client::Teams::AdSlotsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @ad_slots = paginate(query_index)
    respond_with_pagination @ad_slots
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

  private

  def query_index
    AdSlotCollection.new(@ad_slots, params)
      .collect
      .preload(:category_groups)
  end

  def ad_slot_params
    params.require(:ad_slot)
      .permit(:name, :dimensions, :affiliate_id, :width, :height, category_group_ids: [])
  end
end
