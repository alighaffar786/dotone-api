namespace :affiliates do
  resources :ad_links, only: [] do
    match :generate, via: [:post, :get], on: :collection
  end

  resources :affiliates, only: [] do
    get :current, on: :collection
  end

  resources :affiliate_stats, only: [] do
    get :conversions, on: :collection
  end

  resources :creatives, only: :index
  resources :deep_links, only: [] do
    post :generate, on: :collection
  end

  resources :products, only: :index
  resources :network_offers, path: 'offers', only: :index

  resources :stat_summaries, path: 'stats', only: :index

  match 'links/generate', to: 'ad_links#generate', via: [:post, :get]
end
