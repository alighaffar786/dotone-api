namespace :advertisers do
  namespace :reports do
    resources :affiliations, only: :index
    resources :stat_summaries, only: :index do
      post :download, on: :collection
    end
    resources :tasks, only: [:index]
  end

  resources :advertiser_balances, only: :index

  resources :affiliate_logs, only: :create

  resources :affiliate_offers, only: [:index, :update]

  data_types = /clicks|captured|converted|published/
  resources :affiliate_stats, only: [] do
    collection do
      get ':data_type', action: :index, data_type: data_types
      post ':data_type/download', action: :download, data_type: data_types
      post :bulk_update
      post :download
      get ':data_type/recent', action: :recent, data_type: data_types
    end
  end

  resources :affiliate_stats, only: [] do
    get :pending_conversions, on: :collection
    get :pending_conversions_by_offer, on: :collection
  end

  resources :affiliate_users, only: :index

  resources :affiliates, only: [:index, :update] do
    collection do
      get :recent
      get :search
    end
  end

  resources :contact_lists, only: [:index, :create, :update]

  resources :client_apis, only: [:index, :create, :update]

  resources :dashboards, only: :index do
    collection do
      get :exposure
      get :account_overview
      get :performance_stat
      get :total_order
      get :visitor
      get :commission_balance
      get :publisher
    end
  end

  resources :downloads, only: [:index, :destroy]

  resources :easy_store_setups, only: [:create] do
    get :find, on: :collection
  end

  resources :image_creatives, only: [:create, :index, :update] do
    put :update_bulk, on: :collection
  end

  resources :missing_orders, only: [:index, :update] do
    post :download, on: :collection
  end

  resources :network_offers, only: :index do
    get :search, on: :collection
  end

  resources :networks, only: [:show, :update] do
    get :current, on: :collection
  end

  resources :orders, only: :update

  resource :password, only: [:create, :update] do
    post :reset
  end

  resources :products, only: :index

  resources :registrations, only: [] do
    post :register, on: :collection
  end

  resources :sessions, only: :create do
    collection do
      post :create_by_token
      post :refresh_token
    end
  end

  resources :site_infos, only: [] do
    get :impressions, on: :member
  end

  resources :text_creatives, only: [:index, :create, :update] do
    put :update_bulk, on: :collection
  end

  resources :uploads, only: [:index, :create]
end
