namespace :advertisers do
  resources :network_offers, path: 'offers', only: :show
  resources :stat_summaries, path: 'stats', only: :index

  resources :orders, only: [] do
    collection do
      post :modify
      get :modify
      post :nine_one_app
      get :nine_one_app
    end
  end

  namespace :webhook do
    resources :easy_stores, only: [] do
      collection do
        match 'update', via: [:get, :post], action: :update, as: :update
        match 'reject', via: [:get, :post], action: :reject, as: :reject
      end
    end
  end
end
