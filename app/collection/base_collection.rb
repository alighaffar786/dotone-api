class BaseCollection
  include BooleanHelper
  include ParamNameHelper

  attr_reader :ability, :params, :sort_field, :sort_order, :currency_code, :time_zone, :authorize

  def initialize(relation, params = {}, currency_code: nil, time_zone: nil, authorize: :read, **_options)
    if relation.is_a?(Ability)
      @ability = relation
      @authorize = authorize
      @relation = self.class.model.accessible_by(ability, authorize)
    else
      @ability = Ability.new(DotOne::Current.user)
    end

    @relation ||= relation
    @params = params
    @params = @params.merge(all_locale: true) if params[:search].present? || params[:ids].present?
    @currency_code = currency_code || params[:currency_code] || Currency.default_code
    @time_zone = time_zone || params[:time_zone] || TimeZone.default
    @sort_field = params[:sort_field]
    @sort_order = params[:sort_order]
  end

  def self.model
    name.gsub('Collection', '').constantize
  end

  def user
    @user ||= ability&.user
  end

  def affiliate?
    user.is_a?(Affiliate)
  end

  def network?
    user.is_a?(Network)
  end

  def affiliate_user?
    user.is_a?(AffiliateUser)
  end

  def affiliate_ability
    return ability if affiliate?
    return if params[:affiliate_id].blank?

    @affiliate_ability ||= begin
      affiliate = Affiliate.find(params[:affiliate_id])
      Ability.new(affiliate)
    end
  end

  def network_ability
    return ability if network?
    return if params[:network_id].blank?

    @network_ability ||= begin
      network = Network.cached_find(params[:network_id])
      Ability.new(network)
    end
  end

  def collect
    ensure_filters
    ensure_sort
  end

  protected

  def filter
    @relation = yield(@relation)
  end

  def filter_by_ids
    filter { @relation.where(id: params[:ids]) }
  end

  def filter_by_limit
    filter { @relation.limit(params[:limit]) }
  end

  def filter_distinct
    filter { @relation.distinct }
  end

  def filter_by_search
    return unless self.class.model.respond_to?(:es_search)

    filter { @relation.es_search(params[:search]) }
  end

  def ensure_filters
    filter_by_ids if params[:ids].present?
    filter_by_limit if params[:limit].present?
    filter_by_search if params[:search].present?
  end

  def ensure_sort
    return @relation if params[:search].present?
    return default_sorted if sort_field.blank?

    sort_method = "sort_by_#{sort_field}"
    if respond_to?(sort_method, true)
      send(sort_method)
    else
      sort_by_field
    end
  end

  def default_sorted
    @relation
  end

  def sort_by_field
    if self.class.model.column_names.include?(sort_field)
      sort { @relation.order(sort_field => sort_order) }
    else
      @relation
    end
  end

  alias sort filter

  def filter_by_group_tag_ids
    filter do
      @relation
        .left_outer_joins(:group_tags)
        .where(affiliate_tags: { id: params[:group_tag_ids] })
        .distinct
    end
  end

  def filter_by_created_at
    filter do
      @relation.between(params[:start_date], params[:end_date], :created_at, time_zone)
    end
  end
end
