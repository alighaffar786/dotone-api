constraints DotOne::Constraints::TrackingConstraint do
  get '/', to: 'track/home#index', as: :home
  # get '/test', to: 'track/home#test', as: :test
  get '/terminal', to: 'track/home#terminal', as: :terminal
  get '/test', to: 'track/home#test', as: :test

  namespace :track do
    with_options via: [:get, :post] do
      match 'clicks/geo_filter/:offer_id' => 'clicks#geo_filter', as: :geo_filter
      # offer click
      match 'clicks/:id/:token' => 'clicks#offer_variant', as: :clicks

      # Affiliate Referral
      match 'affr/:affiliate_id' => 'clicks#affiliate_referral', as: :affr

      # form redirect
      match 'clicks/form_redirect' => 'clicks#form_redirect', as: :form_redirect

      # Offer Conversion Pixels
      match 'conversions/:wl_id/:id' => 'conversions#global', as: :conversions
      match 'postback/conversions/:wl_id/global' => 'conversions#offer', as: :postback_global_conversions
      match 'postback/conversions/:wl_id/:id' => 'conversions#offer', as: :postback_conversions

      # image creative impression
      match 'imp/img/:id/:token' => 'impressions#image_creative', as: :imp_img

      # ad slot impression
      match 'imp/ad_slot/:id/:width/:height' => 'impressions#ad_slot', as: :ad_slot_impression
    end

    # ========================================================

    resources :conversions, only: [] do
      collection do
        get :global
        get :offer
      end
    end

    resources :impressions, only: [] do
      collection do
        get :mkt_site
        get :iframe
      end
    end
  end
end
