class Api::Client::Teams::OwnerHasTagsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @owner_has_tags = paginate(query_index)
    respond_with_pagination @owner_has_tags, owner: include_owner?, owners: query_owners(@owner_has_tags)
  end

  def create
    if @owner_has_tag.save
      respond_with @owner_has_tag, owner: include_owner?, owners: query_owners([@owner_has_tag])
    else
      respond_with @owner_has_tag, status: :unprocessable_entity
    end
  end

  def destroy
    if @owner_has_tag.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def sort
    authorize! :update, OwnerHasTag

    @owner_has_tags = @owner_has_tags
      .where(id: params[:ids])
      .order(Arel.sql("FIELD(id, #{params[:ids].join(',')})"))

    @owner_has_tags.each do |tag|
      tag.update(display_order: params[:ids].index(tag.id))
    end

    head 200
  end

  private

  def query_index
    collection = OwnerHasTagCollection.new(current_ability, params).collect.ordered.preload(:affiliate_tag)
    collection = collection.preload(:owner) if include_owner? && params[:owner_type] != 'Offer'
    collection
  end

  def query_owners(tags)
    return {} unless include_owner?

    offer_ids = tags.select { |tag| tag.owner_type == 'Offer' }.map(&:owner_id)

    if offer_ids.present?
      offers = NetworkOffer
        .where(id: offer_ids)
        .agg_affiliate_pay(nil, current_currency_code)
        .preload(:name_translations, :default_offer_variant, :brand_image_large, :brand_image_small)
        .index_by(&:id)

      tags.each_with_object({}) do |tag, result|
        result[tag.id] = offers[tag.owner_id]
      end
    end
  end

  def include_owner?
    truthy?(params[:owner])
  end

  def owner_has_tag_params
    params.require(:owner_has_tag).permit(:affiliate_tag_id, :access_type, :owner_type, :owner_id, :display_order)
  end
end
