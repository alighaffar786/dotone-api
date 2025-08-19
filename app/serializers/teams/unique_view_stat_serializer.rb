class Teams::UniqueViewStatSerializer < ApplicationSerializer
  [:clicks, :impressions, :captured, :click_through, :conversion_through].each do |attr|
    attribute attr do
      object[attr]
    end
  end

  has_one :affiliate, serializer: Teams::Affiliate::UniqueViewStatSerializer

  def affiliate
    instance_options[:affiliates].try(:[], object[:affiliate_id])
  end
end
