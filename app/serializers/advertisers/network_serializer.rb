class Advertisers::NetworkSerializer < Base::NetworkSerializer
  attributes :id, :avatar_cdn_url, :contact_email, :name, :contact_name, :contact_phone, :country_id, :company_url,
    :brands, :category_group_ids, :type, :pro?, :partial_pro?, :has_product_api?, :tfa_enabled

  has_many :category_groups
  has_one :country

  def include_config?
    true
  end

  def has_product_api?
    current_ability.can?(:read, Product)
  end
end
