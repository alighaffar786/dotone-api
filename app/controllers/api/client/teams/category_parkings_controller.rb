class Api::Client::Teams::CategoryParkingsController < Api::Client::Teams::BaseController
  def index
    authorize! :read_parking, Category
    @categories = Category.order(:name).like(params[:search]).to_a

    respond_with @categories, each_serializer: Teams::CategoryParkingSerializer, offers_count: offers_count
  end

  private

  def offers_count
    parking_name_index_start = AffiliateTag::NAME_FOR_PARKING_OFFER_CATEGORY.length + 1

    OwnerHasTag
      .select('categories.id AS category_id, COUNT(*) AS offers_count')
      .joins(:affiliate_tag)
      .joins("INNER JOIN categories ON categories.id = COALESCE(SUBSTRING(affiliate_tags.name, #{parking_name_index_start}), NULL)")
      .where('affiliate_tags.name LIKE ?', "#{AffiliateTag::NAME_FOR_PARKING_OFFER_CATEGORY}%")
      .where(owner_has_tags: { owner_type: 'Offer' }, categories: { id: @categories.map(&:id) })
      .group('categories.id')
      .to_h { |tag| [tag.category_id, tag.offers_count] }
  end
end
