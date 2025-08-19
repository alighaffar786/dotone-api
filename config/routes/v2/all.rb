namespace :v2 do
  constraints DotOne::Constraints::ApiV2AdvertiserConstraint do
    draw 'v2/advertisers'

    resources :product_categories, only: :index
  end

  constraints DotOne::Constraints::ApiV2AffiliateConstraint do
    draw 'v2/affiliates'

    resources :product_categories, only: :index
  end
end
