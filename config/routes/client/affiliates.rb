namespace :affiliates do
  providers = /instagram|facebook|line|google_oauth2|youtube|tiktok/

  get 'auth/failure', to: 'auth#failure'

  with_options provider: providers do |opt|
    opt.match 'auth/:provider/callback', to: 'auth#callback', via: [:get, :post]
    opt.post 'auth/:provider/deauthorize', to: 'auth#deauthorize'
    opt.post 'auth/:provider/deletion', to: 'auth#deletion'
  end

  namespace :auth do
    with_options provider: providers do |opt|
      opt.match 'site_infos/:provider/callback', to: 'site_infos#callback', via: [:get, :post]
    end
  end

  namespace :reports do
    resources :referrals, only: :index do
      get :summary, on: :collection
    end

    resources :stat_summaries, only: :index do
      get :download, on: :collection
    end

    resources :stats, only: [] do
      get :performance_summary, on: :collection
      get :confirmed_summary, on: :collection
    end
  end

  resources :access_tokens, except: [:new, :edit, :show]

  resources :ad_slots, except: [:new, :edit, :show] do
    get :recent, on: :collection
  end

  resources :affiliates, only: [:show, :update] do
    get :current, on: :collection
    post :generate_ad_link, on: :member
  end

  resource :affiliate_address, only: [:show, :update]

  resources :affiliate_offers, only: [:create, :update, :destroy] do
    get :get, on: :collection
    post :generate_url, on: :member
  end

  data_types = /clicks|captured|converted|published/
  resources :affiliate_stats, only: [] do
    get ':data_type', on: :collection, action: :index, data_type: data_types
    get ':data_type/recent', on: :collection, action: :recent, data_type: data_types
    post ':data_type/download', on: :collection, action: :download, data_type: data_types
  end

  resources :affiliate_users, only: :index

  resources :downloads, only: [:index, :destroy]

  resources :event_affiliate_offers, only: [:create, :update] do
    get :get, on: :collection
  end

  resources :event_offers, only: [:index, :show] do
    collection do
      get :recent
      get :personalized
    end
  end

  resources :image_creatives, only: :index do
    post :record_download, on: :member
  end

  resources :missing_orders, only: [:index, :create]

  resources :network_offers, only: [:index, :show] do
    get :search, on: :collection
    get :top_offers, on: :collection
    get :by_tag, on: :collection
    get :similar, on: :member
  end

  resources :orders, only: [] do
    get :search, on: :collection
  end

  resources :offer_variants, only: :index

  resources :partner_apps, only: :index

  resource :password, only: [:create, :update] do
    post :reset
  end

  resources :payments, only: :index do
    get :recent, on: :collection
    post :redeem, on: :member
  end

  resource :payment_info, only: [:show, :update] do
    post :verify
  end

  resources :phone_verifications, only: :create do
    put :verify, on: :member
  end

  resources :products, only: [] do
    collection do
      get :search
      get :quick_search
    end
  end

  resources :registrations, only: [] do
    collection do
      post :register
      post :resend_verification
      post :verify
    end
  end

  resources :sessions, only: :create do
    collection do
      post :create_by_token
      post :refresh_token
    end
  end

  resources :site_infos, except: [:new, :edit, :show]

  resources :text_creatives, only: :index do
    get :recent, on: :collection
    get :search, on: :collection
  end

  resources :popup_feeds, only: :index
end
