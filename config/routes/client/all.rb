namespace :client, defaults: { format: :json }, constraints: DotOne::Constraints::ClientApiConstraint do
  draw 'client/advertisers'
  draw 'client/affiliates'
  draw 'client/teams'

  resources :affiliate_feeds, path: 'feeds', only: :index do
    get :recent, on: :collection
  end

  resources :affiliate_tags, only: :index do
    get :media_categories, on: :collection
    get :target_devices, on: :collection
    get :event_media_categories, on: :collection
  end

  resources :chat_rooms, only: [:index, :create] do
    resources :chat_messages, only: [:index, :create]
    resources :participants, only: [:index, :create]
  end

  resources :banks, only: :index do
    get :branches, on: :member
  end

  resource :app_config, only: :show
  resources :api_keys, except: [:new, :edit, :show]
  resources :categories, only: :index
  resources :category_groups, only: [:index, :update]
  resources :chatbot_steps, only: :index
  resources :countries, only: [:index, :create, :update, :destroy]
  resources :currencies, only: :index
  resources :domains, only: :index
  resources :expertises, only: :index
  resources :faq_feeds, only: :index

  resources :mkt_sites, only: [] do
    get :get_code, on: :member
  end

  resources :search_keys, only: :create
  resources :time_zones, only: :index

  resources :tracking_urls, only: [] do
    collection do
      post :generate_global_conversion_url
    end
  end

  resource :platform, only: :show
end
